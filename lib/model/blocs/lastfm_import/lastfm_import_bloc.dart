import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/database_error.dart';
import 'package:moodtag/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/exceptions/user_readable/invalid_user_input_exception.dart';
import 'package:moodtag/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/exceptions/user_readable/user_readable_exception.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_bloc.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_flow_step.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_option.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_state.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/model/events/lastfm_import_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/screens/lastfm_import/lastfm_connector.dart' as LastFmConnector;

class LastFmImportBloc extends AbstractImportBloc<LastFmImportState> with ErrorStreamHandling {
  late final StreamSubscription<LastFmAccount?> _accountStreamSubscription;

  LastFmImportBloc(Repository repository, BuildContext mainContext) : super(LastFmImportState(), repository) {
    on<LastFmAccountUpdated>(_handleLastFmAccountUpdatedEvent);
    on<AddLastFmAccount>(_handleAddLastFmAccountEvent);
    on<RemoveLastFmAccount>(_handleRemoveLastFmAccountEvent);
    on<UpdateLastFmAccountInfo>(_handleUpdateLastFmAccountInfoEvent);
    on<ReturnToPreviousImportScreen>(_handleReturnToPreviousImportScreenEvent);
    on<ChangeImportConfig>(_handleChangeImportConfigEvent);
    on<ConfirmImportConfig>(_handleConfirmImportConfigEvent);
    on<ConfirmArtistsForImport>(_handleConfirmArtistsForImportEvent);
    on<ConfirmTagsForImport>(_handleConfirmTagsForImportEvent);
    on<CompleteLastFmImport>(_handleCompleteImportEvent);

    _accountStreamSubscription = repository
        .getLastFmAccount()
        .handleError((error) => add(LastFmAccountUpdated(error: error)))
        .listen((accountName) => add(LastFmAccountUpdated(lastFmAccount: accountName)));

    // TODO Context seems not to be correct for LastFmImportScreen;
    //  some Snackbars are only shown after returning to ArtistsList
    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() {
    _accountStreamSubscription.cancel();
    return super.close();
  }

  void _handleLastFmAccountUpdatedEvent(LastFmAccountUpdated event, Emitter<LastFmImportState> emit) async {
    if (event.error != null) {
      errorStreamController
          .add(DatabaseError("The Last.fm account name could not be retrieved from the database.", cause: event.error));
      emit(state.copyWith(lastFmAccount: null, accountNameLoadingStatus: LoadingStatus.error, removeAccount: true));
    } else {
      emit(state.copyWith(
          lastFmAccount: event.lastFmAccount,
          accountNameLoadingStatus: LoadingStatus.success,
          removeAccount: event.lastFmAccount == null));
    }
  }

  void _handleAddLastFmAccountEvent(AddLastFmAccount event, Emitter<LastFmImportState> emit) async {
    final createdAccountUserInfo = await _createOrUpdateLastFmAccount(state.lastFmAccount!.accountName);
    if (createdAccountUserInfo != null) {
      emit(state.copyWith(lastFmAccount: createdAccountUserInfo));
    }
  }

  void _handleRemoveLastFmAccountEvent(RemoveLastFmAccount event, Emitter<LastFmImportState> emit) async {
    final exception = await createEntityBlocHelper.handleRemoveLastFmAccount(repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _handleUpdateLastFmAccountInfoEvent(UpdateLastFmAccountInfo event, Emitter<LastFmImportState> emit) async {
    if (state.lastFmAccount == null) {
      errorStreamController
          .add(ExternalServiceQueryException('Update of Last.fm account info failed: No account configured'));
      return;
    }

    final updatedUserInfo = await _createOrUpdateLastFmAccount(state.lastFmAccount!.accountName);
    if (updatedUserInfo != null) {
      emit(state.copyWith(lastFmAccount: updatedUserInfo));
    }
  }

  Future<LastFmAccount?> _createOrUpdateLastFmAccount(String accountName) async {
    try {
      final userInfo = await LastFmConnector.getUserInfo(accountName);
      final exception = await createEntityBlocHelper.handleCreateOrUpdateLastFmAccountEvent(userInfo, repository);
      if (exception != null) {
        errorStreamController.add(exception);
      } else {
        return userInfo;
      }
    } on UserReadableException catch (e) {
      errorStreamController.add(e);
    } catch (e) {
      errorStreamController
          .add(ExternalServiceQueryException('The request to the Last.fm API failed for an unknown reason.', cause: e));
    }
    return null;
  }

  void _handleReturnToPreviousImportScreenEvent(ReturnToPreviousImportScreen event, Emitter<LastFmImportState> emit) {
    if (state.step.index > LastFmImportFlowStep.config.index) {
      emit(state.copyWith(step: LastFmImportFlowStep.values[state.step.index - 1]));
    }
  }

  void _handleChangeImportConfigEvent(ChangeImportConfig event, Emitter<LastFmImportState> emit) async {
    final selectedOptions = event.selectedOptions;
    final Map<LastFmImportOption, bool> configItemsWithSelection = {
      LastFmImportOption.allTimeTopArtists: selectedOptions[LastFmImportOption.allTimeTopArtists.name] ?? false,
      LastFmImportOption.lastMonthTopArtists: selectedOptions[LastFmImportOption.lastMonthTopArtists.name] ?? false,
    };
    emit(state.copyWith(configuration: configItemsWithSelection));
  }

  void _handleConfirmImportConfigEvent(ConfirmImportConfig event, Emitter<LastFmImportState> emit) async {
    // TODO
  }

  void _handleConfirmArtistsForImportEvent(ConfirmArtistsForImport event, Emitter<LastFmImportState> emit) async {
    if (event.selectedArtists.isEmpty) {
      errorStreamController.add(InvalidUserInputException("No artists selected for import."));
    } else {
      final availableTagsForSelectedArtists = await getAvailableTagsForSelectedArtists(event.selectedArtists);

      emit(state.copyWith(
          selectedArtists: event.selectedArtists,
          availableTagsForSelectedArtists: availableTagsForSelectedArtists,
          step: _getNextFlowStep(state)));
    }
  }

  void _handleConfirmTagsForImportEvent(ConfirmTagsForImport event, Emitter<LastFmImportState> emit) {
    if (state.availableTagsForSelectedArtists == null) {
      errorStreamController.add(UnknownError("Something went wrong: Tags are not available for import."));
    } else if (event.selectedTags.isEmpty && state.availableTagsForSelectedArtists!.isEmpty == false) {
      errorStreamController.add(InvalidUserInputException("No tags selected for import."));
    } else {
      emit(state.copyWith(selectedTags: event.selectedTags, step: _getNextFlowStep(state)));
    }
  }

  void _handleCompleteImportEvent(CompleteLastFmImport event, Emitter<LastFmImportState> emit) async {
    // TODO
    // final Map<ImportSubProcess, DbRequestSuccessCounter> successCounters =
    //     await _spotifyImportProcessor.conductImport(event.selectedArtists, event.selectedGenres, _repository);
    // final resultMessage = getResultMessage(successCounters);
    // errorStreamController.add(UserInfo(resultMessage));

    emit(state.copyWith(isFinished: true));
  }

  LastFmImportFlowStep _getNextFlowStep(LastFmImportState currentState) {
    return LastFmImportFlowStep.values[currentState.step.index + 1];
  }
}
