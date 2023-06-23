import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/database_error.dart';
import 'package:moodtag/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/exceptions/user_readable/user_readable_exception.dart';
import 'package:moodtag/model/bloc_helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_state.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/lastfm_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/screens/lastfm_import/lastfm_connector.dart' as LastFmConnector;

class LastFmImportBloc extends Bloc<LastFmEvent, LastFmImportState> with ErrorStreamHandling {
  final Repository _repository;
  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  late final StreamSubscription<LastFmAccount?> _accountStreamSubscription;

  LastFmImportBloc(this._repository, BuildContext mainContext) : super(LastFmImportState()) {
    on<LastFmAccountUpdated>(_mapLastFmAccountUpdatedEventToState);
    on<AddLastFmAccount>(_mapAddLastFmAccountEventToState);
    on<RemoveLastFmAccount>(_mapRemoveLastFmAccountEventToState);
    on<UpdateLastFmAccountInfo>(_mapUpdateLastFmAccountInfoEventToState);

    _accountStreamSubscription = _repository
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

  void _mapLastFmAccountUpdatedEventToState(LastFmAccountUpdated event, Emitter<LastFmImportState> emit) async {
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

  void _mapAddLastFmAccountEventToState(AddLastFmAccount event, Emitter<LastFmImportState> emit) async {
    final createdAccountUserInfo = await _createOrUpdateLastFmAccount(state.lastFmAccount!.accountName);
    if (createdAccountUserInfo != null) {
      emit(state.copyWith(lastFmAccount: createdAccountUserInfo));
    }
  }

  void _mapRemoveLastFmAccountEventToState(RemoveLastFmAccount event, Emitter<LastFmImportState> emit) async {
    final exception = await _createEntityBlocHelper.handleRemoveLastFmAccount(_repository);
    if (exception != null) {
      errorStreamController.add(exception);
    }
  }

  void _mapUpdateLastFmAccountInfoEventToState(UpdateLastFmAccountInfo event, Emitter<LastFmImportState> emit) async {
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
      final exception = await _createEntityBlocHelper.handleCreateOrUpdateLastFmAccountEvent(userInfo, _repository);
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
  }
}
