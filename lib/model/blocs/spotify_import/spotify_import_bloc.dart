import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/exceptions/user_readable/invalid_user_input_exception.dart';
import 'package:moodtag/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/exceptions/user_readable/user_info.dart';
import 'package:moodtag/model/blocs/abstract_import/abstract_import_bloc.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/spotify_auth/spotify_access_token_provider.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_option.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_processor.dart';
import 'package:moodtag/model/events/import_events.dart';
import 'package:moodtag/model/events/spotify_import_events.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/screens/spotify_import/spotify_connector.dart';
import 'package:moodtag/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';

import 'spotify_import_flow_step.dart';
import 'spotify_import_state.dart';

class SpotifyImportBloc extends AbstractImportBloc<SpotifyImportState> with ErrorStreamHandling {
  final SpotifyImportProcessor _spotifyImportProcessor = SpotifyImportProcessor();

  final SpotifyAccessTokenProvider accessTokenProvider;

  SpotifyImportBloc(Repository repository, BuildContext mainContext, this.accessTokenProvider)
      : super(SpotifyImportState(configuration: _getInitialImportConfig()), repository) {
    on<ReturnToPreviousImportScreen>(_handleReturnToPreviousImportScreenEvent);
    on<ChangeImportConfig>(_handleChangeImportConfigEvent);
    on<ConfirmImportConfig>(_handleConfirmImportConfigEvent);
    on<ConfirmSpotifyArtistsForImport>(_handleConfirmSpotifyArtistsForImportEvent);
    on<ConfirmGenreTagsForImport>(_handleConfirmGenreTagsForImportEvent);
    on<CompleteSpotifyImport>(_handleCompleteImportEvent);

    setupErrorHandler(mainContext);
  }

  static Map<SpotifyImportOption, bool> _getInitialImportConfig() {
    Map<SpotifyImportOption, bool> initialConfig = {};
    SpotifyImportOption.values.forEach((option) {
      initialConfig[option] = true;
    });
    return initialConfig;
  }

  void _handleReturnToPreviousImportScreenEvent(ReturnToPreviousImportScreen event, Emitter<SpotifyImportState> emit) {
    if (state.step.index > SpotifyImportFlowStep.config.index) {
      emit(state.copyWith(step: SpotifyImportFlowStep.values[state.step.index - 1]));
    }
  }

  void _handleChangeImportConfigEvent(ChangeImportConfig event, Emitter<SpotifyImportState> emit) async {
    final selectedOptions = event.selectedOptions;
    final Map<SpotifyImportOption, bool> configItemsWithSelection = {
      SpotifyImportOption.topArtists: selectedOptions[SpotifyImportOption.topArtists.name] ?? false,
      SpotifyImportOption.followedArtists: selectedOptions[SpotifyImportOption.followedArtists.name] ?? false,
      SpotifyImportOption.artistGenres: selectedOptions[SpotifyImportOption.artistGenres.name] ?? false,
    };
    emit(state.copyWith(configuration: configItemsWithSelection));
  }

  void _handleConfirmImportConfigEvent(ConfirmImportConfig event, Emitter<SpotifyImportState> emit) async {
    try {
      if (!state.isConfigurationValid) {
        errorStreamController.add(InvalidUserInputException("Nothing selected for import."));
        return;
      }

      SpotifyAccessToken? accessToken = await accessTokenProvider.getAccessToken();
      if (accessToken == null) {
        errorStreamController.add(ExternalServiceQueryException('Authorization to Spotify Web API failed.'));
        return;
      }

      final availableSpotifyArtists = await _getAvailableSpotifyArtists(state.configuration, accessToken.token);

      if (availableSpotifyArtists.isEmpty) {
        errorStreamController.add(InvalidUserInputException("No artists to import."));
      } else {
        emit(state.copyWith(availableSpotifyArtists: availableSpotifyArtists, step: _getNextFlowStep(state)));
      }
    } on ExternalServiceQueryException catch (e) {
      print("Getting available artists from Spotify failed: $e");
      errorStreamController.add(e);
    } catch (e) {
      print("Getting available artists from Spotify failed: $e");
      errorStreamController.add(
          ExternalServiceQueryException("Internal error - could not retrieve artists from the Spotify API.", cause: e));
    }
  }

  Future<UniqueNamedEntitySet<SpotifyArtist>> _getAvailableSpotifyArtists(
      Map<SpotifyImportOption, bool> selectedOptions, String accessToken) async {
    final availableSpotifyArtists = UniqueNamedEntitySet<SpotifyArtist>();

    if (selectedOptions[SpotifyImportOption.topArtists] == true) {
      availableSpotifyArtists.addAll(await getTopArtists(accessToken, 50, 0));
    }

    if (selectedOptions[SpotifyImportOption.followedArtists] == true) {
      availableSpotifyArtists.addAll(await getFollowedArtists(accessToken));
    }

    if (!availableSpotifyArtists.isEmpty) {
      await annotateImportEntitiesWithAlreadyExistsProp(availableSpotifyArtists);
    }

    return availableSpotifyArtists;
  }

  void _handleConfirmSpotifyArtistsForImportEvent(
      ConfirmSpotifyArtistsForImport event, Emitter<SpotifyImportState> emit) async {
    if (event.selectedArtists.isEmpty) {
      errorStreamController.add(InvalidUserInputException("No artists selected for import."));
    } else {
      final availableGenresForSelectedArtists = await getAvailableTagsForSelectedArtists(event.selectedArtists);

      emit(state.copyWith(
          selectedArtists: event.selectedArtists,
          availableGenresForSelectedArtists: availableGenresForSelectedArtists,
          step: _getNextFlowStep(state)));
    }
  }

  void _handleConfirmGenreTagsForImportEvent(ConfirmGenreTagsForImport event, Emitter<SpotifyImportState> emit) {
    if (state.availableGenresForSelectedArtists == null) {
      errorStreamController.add(UnknownError("Something went wrong: Genres are not available for import."));
    } else if (event.selectedGenres.isEmpty && state.availableGenresForSelectedArtists!.isEmpty == false) {
      errorStreamController.add(InvalidUserInputException("No genres selected for import."));
    } else {
      emit(state.copyWith(selectedGenres: event.selectedGenres, step: _getNextFlowStep(state)));
    }
  }

  void _handleCompleteImportEvent(CompleteSpotifyImport event, Emitter<SpotifyImportState> emit) async {
    final Map<ImportSubProcess, DbRequestSuccessCounter> successCounters =
        await _spotifyImportProcessor.conductImport(event.selectedArtists, event.selectedGenres, repository);
    final resultMessage = getResultMessage(successCounters);
    errorStreamController.add(UserInfo(resultMessage));

    emit(state.copyWith(isFinished: true));
  }

  SpotifyImportFlowStep _getNextFlowStep(SpotifyImportState currentState) {
    if (currentState.step == SpotifyImportFlowStep.artistsSelection && !currentState.doImportGenres) {
      return SpotifyImportFlowStep.confirmation;
    }
    return SpotifyImportFlowStep.values[currentState.step.index + 1];
  }
}
