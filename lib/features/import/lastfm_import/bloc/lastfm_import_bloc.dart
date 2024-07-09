import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_bloc.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_state.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_config.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_option.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_period.dart';
import 'package:moodtag/features/import/lastfm_import/flow/lastfm_import_flow_step.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/import_events.dart';
import 'package:moodtag/shared/bloc/events/lastfm_import_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/bloc/extensions/error_handling/error_stream_handling.dart';
import 'package:moodtag/shared/bloc/helpers/create_entity_bloc_helper.dart';
import 'package:moodtag/shared/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/invalid_user_input_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/user_info.dart';
import 'package:moodtag/shared/models/structs/imported_entities/lastfm_artist.dart';
import 'package:moodtag/shared/models/structs/imported_entities/unique_import_entity_set.dart';
import 'package:moodtag/shared/utils/optional.dart';

import '../connectors/lastfm_connector.dart';
import '../connectors/lastfm_import_processor.dart';

class LastFmImportBloc extends AbstractImportBloc<LastFmImportState> with ErrorStreamHandling {
  final LastFmImportProcessor _lastFmImportProcessor = LastFmImportProcessor();

  final Repository _repository;

  final CreateEntityBlocHelper _createEntityBlocHelper = CreateEntityBlocHelper();

  LastFmImportBloc(this._repository, BuildContext mainContext) : super(LastFmImportState(), _repository) {
    on<InitializeImport>(_handleInitializeImport);

    // TODO Context seems not to be correct for LastFmImportScreen;
    //      some Snackbars are only shown after returning to ArtistsList
    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    super.close();
    closeErrorStreamController();
  }

  void _handleInitializeImport(InitializeImport event, Emitter<LastFmImportState> emit) async {
    on<ReturnToPreviousImportScreen>(_handleReturnToPreviousImportScreenEvent);
    on<ChangeImportConfig>(_handleChangeImportConfigEvent);
    on<ConfirmImportConfig>(_handleConfirmImportConfigEvent);
    on<ConfirmLastFmArtistsForImport>(_handleConfirmLastFmArtistsForImportEvent);
    on<CompleteLastFmImport>(_handleCompleteImportEvent);
    on<CreateTags>(_handleCreateTags);

    final tagCategories = await repository.getTagCategoriesOnce();
    final tags = await repository.getTagsOnce();
    final initialImportConfig = _getInitialImportConfig(tagCategories);
    emit(state.copyWith(
        isInitialized: true,
        allTagCategories: LoadedData.success(tagCategories),
        allTags: LoadedData.success(tags),
        importConfig: initialImportConfig));
  }

  LastFmImportConfig _getInitialImportConfig(List<TagCategory> tagCategories) {
    Map<LastFmImportOption, bool> initialImportOptions = {};
    LastFmImportOption.values.forEach((option) {
      initialImportOptions[option] = true;
    });

    final defaultTagCategory = tagCategories.first;
    return LastFmImportConfig(categoryForTags: defaultTagCategory, options: initialImportOptions);
  }

  void _handleReturnToPreviousImportScreenEvent(ReturnToPreviousImportScreen event, Emitter<LastFmImportState> emit) {
    if (state.step.index > LastFmImportFlowStep.config.index) {
      emit(state.copyWith(step: LastFmImportFlowStep.values[state.step.index - 1]));
    }
  }

  void _handleChangeImportConfigEvent(ChangeImportConfig event, Emitter<LastFmImportState> emit) async {
    Optional<Map<LastFmImportOption, bool>> importOptions = event.checkboxSelections.isPresent
        ? Optional({
            LastFmImportOption.allTimeTopArtists:
                event.checkboxSelections.content![LastFmImportOption.allTimeTopArtists] == true,
            LastFmImportOption.lastMonthTopArtists:
                event.checkboxSelections.content![LastFmImportOption.lastMonthTopArtists] == true,
          })
        : Optional<Map<LastFmImportOption, bool>>.none();

    final newImportConfig = state.importConfig!.copyWith(
        options: importOptions, categoryForTags: event.newTagCategory, initialTagForArtists: event.newInitialTag);
    emit(state.copyWith(importConfig: newImportConfig));
  }

  void _handleConfirmImportConfigEvent(ConfirmImportConfig event, Emitter<LastFmImportState> emit) async {
    try {
      if (!state.isInitialized || state.importConfig == null) return;

      if (!state.importConfig!.isValid) {
        final errorMessage =
            state.importConfig!.categoryForTags == null ? "No tag category selected." : "Nothing selected for import.";
        errorStreamController.add(InvalidUserInputException(errorMessage));
        return;
      }

      LastFmAccount? lastFmAccount = await repository.getLastFmAccountOnce();
      if (lastFmAccount == null) {
        errorStreamController.add(InvalidUserInputException("Could not retrieve the configured Last.fm account."));
        return;
      }

      final availableLastFmArtists = await _getAvailableLastFmArtists(lastFmAccount);

      if (availableLastFmArtists.isEmpty) {
        errorStreamController.add(InvalidUserInputException("No artists to import."));
      } else {
        emit(state.copyWith(availableLastFmArtists: availableLastFmArtists, step: _getNextFlowStep(state)));
      }
    } on ExternalServiceQueryException catch (e) {
      print("Getting available artists from Last.fm failed: $e");
      errorStreamController.add(e);
    } catch (e) {
      print("Getting available artists from Last.fm failed: $e");
      errorStreamController.add(
          ExternalServiceQueryException("Internal error - could not retrieve artists from the Last.fm API.", cause: e));
    }
  }

  Future<UniqueImportEntitySet<LastFmArtist>> _getAvailableLastFmArtists(LastFmAccount lastFmAccount) async {
    final availableLastFmArtists = UniqueImportEntitySet<LastFmArtist>();

    if (state.importConfig!.options[LastFmImportOption.allTimeTopArtists] == true) {
      availableLastFmArtists.addAll(await getTopArtists(lastFmAccount.name, LastFmImportPeriod.overall, 1000));
    }

    if (state.importConfig!.options[LastFmImportOption.lastMonthTopArtists] == true) {
      final lastMonthTopArtists = await getTopArtists(lastFmAccount.name, LastFmImportPeriod.one_month, 1000);
      availableLastFmArtists.addOrUpdateAll(lastMonthTopArtists, _combineLastFmArtistPlays);
    }

    if (!availableLastFmArtists.isEmpty) {
      await annotateImportedArtistsWithAlreadyExistsProp(availableLastFmArtists);
    }

    return availableLastFmArtists;
  }

  LastFmArtist _combineLastFmArtistPlays(LastFmArtist existingArtist, LastFmArtist duplicate) {
    for (MapEntry<LastFmImportPeriod, int> playCountEntry in duplicate.playCounts.entries) {
      existingArtist.playCounts[playCountEntry.key] = playCountEntry.value;
    }
    return existingArtist;
  }

  void _handleConfirmLastFmArtistsForImportEvent(
      ConfirmLastFmArtistsForImport event, Emitter<LastFmImportState> emit) async {
    if (event.selectedArtists.isEmpty) {
      errorStreamController.add(InvalidUserInputException("No artists selected for import."));
    } else {
      emit(state.copyWith(selectedArtists: event.selectedArtists, step: _getNextFlowStep(state)));
    }
  }

  void _handleCompleteImportEvent(CompleteLastFmImport event, Emitter<LastFmImportState> emit) async {
    await _lastFmImportProcessor.conductImport(
        event.selectedArtists, state.importConfig?.initialTagForArtists, _repository);

    // TODO Give a more specific message, including information on potential errors
    final resultMessage = "Imported ${event.selectedArtists.length} artists.";
    errorStreamController.add(UserInfo(resultMessage));

    emit(state.copyWith(isFinished: true));
  }

  void _handleCreateTags(CreateTags event, Emitter<LastFmImportState> emit) async {
    final (_, exception) = await _createEntityBlocHelper.handleCreateTagsEvent(event, _repository);
    if (exception != null) {
      errorStreamController.add(exception);
    } else {
      final updatedTags = await repository.getTagsOnce();
      emit(state.copyWith(allTags: LoadedData.success(updatedTags)));
    }
  }

  LastFmImportFlowStep _getNextFlowStep(LastFmImportState currentState) {
    return LastFmImportFlowStep.values[currentState.step.index + 1];
  }
}
