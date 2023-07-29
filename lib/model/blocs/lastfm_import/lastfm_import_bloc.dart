import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/invalid_user_input_exception.dart';
import 'package:moodtag/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_bloc.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_flow_step.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_option.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_state.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/model/events/lastfm_import_events.dart';
import 'package:moodtag/model/repository/repository.dart';

class LastFmImportBloc extends AbstractImportBloc<LastFmImportState> with ErrorStreamHandling {
  LastFmImportBloc(Repository repository, BuildContext mainContext) : super(LastFmImportState(), repository) {
    on<ReturnToPreviousImportScreen>(_handleReturnToPreviousImportScreenEvent);
    on<ChangeImportConfig>(_handleChangeImportConfigEvent);
    on<ConfirmImportConfig>(_handleConfirmImportConfigEvent);
    on<ConfirmLastFmArtistsForImport>(_handleConfirmLastFmArtistsForImportEvent);
    on<ConfirmTagsForImport>(_handleConfirmTagsForImportEvent);
    on<CompleteLastFmImport>(_handleCompleteImportEvent);

    // TODO Context seems not to be correct for LastFmImportScreen;
    //  some Snackbars are only shown after returning to ArtistsList
    setupErrorHandler(mainContext);
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

  void _handleConfirmLastFmArtistsForImportEvent(
      ConfirmLastFmArtistsForImport event, Emitter<LastFmImportState> emit) async {
    if (event.selectedArtists.isEmpty) {
      errorStreamController.add(InvalidUserInputException("No artists selected for import."));
    } else {
      // TODO
      // final availableTagsForSelectedArtists = await getAvailableTagsForSelectedArtists(event.selectedArtists);

      emit(state.copyWith(
          selectedArtists: event.selectedArtists,
          // availableTagsForSelectedArtists: availableTagsForSelectedArtists,
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
