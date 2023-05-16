import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/exceptions/external_service_query_exception.dart';
import 'package:moodtag/exceptions/invalid_user_input_exception.dart';
import 'package:moodtag/exceptions/unknown_error.dart';
import 'package:moodtag/exceptions/user_info.dart';
import 'package:moodtag/model/blocs/error_stream_handling.dart';
import 'package:moodtag/model/blocs/spotify_auth/spotify_access_token_provider.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_processor.dart';
import 'package:moodtag/model/events/spotify_events.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/screens/spotify_import/spotify_connector.dart';
import 'package:moodtag/screens/spotify_import/spotify_import_config_screen.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';

import 'spotify_import_state.dart';

enum SpotifyImportFlowStep { config, artistsSelection, genreTagsSelection, confirmation, finished }

class SpotifyImportBloc extends Bloc<SpotifyEvent, SpotifyImportState> with ErrorStreamHandling {
  final Repository _repository;
  final SpotifyImportProcessor _spotifyImportProcessor = SpotifyImportProcessor();

  final SpotifyAccessTokenProvider accessTokenProvider;

  SpotifyImportBloc(this._repository, BuildContext mainContext, this.accessTokenProvider)
      : super(SpotifyImportState(configuration: _getInitialImportConfig())) {
    on<ReturnToPreviousImportScreen>(_mapReturnToPreviousImportScreenEventToState);
    on<ChangeConfigForSpotifyImport>(_mapChangeConfigForSpotifyImportEventToState);
    on<ConfirmConfigForSpotifyImport>(_mapConfirmConfigForSpotifyImportEventToState);
    on<ConfirmArtistsForSpotifyImport>(_mapConfirmArtistsForSpotifyImportEventToState);
    on<ConfirmGenreTagsForSpotifyImport>(_mapConfirmGenreTagsForSpotifyImportEventToState);
    on<CompleteSpotifyImport>(_mapCompleteSpotifyImportEventToState);

    setupErrorHandler(mainContext);
  }

  static Map<SpotifyImportOption, bool> _getInitialImportConfig() {
    Map<SpotifyImportOption, bool> initialConfig = {};
    SpotifyImportOption.values.forEach((option) {
      initialConfig[option] = true;
    });
    return initialConfig;
  }

  void _mapReturnToPreviousImportScreenEventToState(
      ReturnToPreviousImportScreen event, Emitter<SpotifyImportState> emit) {
    if (state.step.index > SpotifyImportFlowStep.config.index) {
      emit(state.copyWith(step: SpotifyImportFlowStep.values[state.step.index - 1]));
    }
  }

  void _mapChangeConfigForSpotifyImportEventToState(
      ChangeConfigForSpotifyImport event, Emitter<SpotifyImportState> emit) async {
    final selectedOptions = event.selectedOptions;
    final Map<SpotifyImportOption, bool> configItemsWithSelection = {
      SpotifyImportOption.topArtists: selectedOptions[SpotifyImportOption.topArtists.name] ?? false,
      SpotifyImportOption.followedArtists: selectedOptions[SpotifyImportOption.followedArtists.name] ?? false,
      SpotifyImportOption.artistGenres: selectedOptions[SpotifyImportOption.artistGenres.name] ?? false,
    };
    emit(state.copyWith(configuration: configItemsWithSelection));
  }

  void _mapConfirmConfigForSpotifyImportEventToState(
      ConfirmConfigForSpotifyImport event, Emitter<SpotifyImportState> emit) async {
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
      errorStreamController
          .add(ExternalServiceQueryException("Internal error - could not retrieve artists from the Spotify API."));
    }
  }

  Future<UniqueNamedEntitySet<ImportedArtist>> _getAvailableSpotifyArtists(
      Map<SpotifyImportOption, bool> selectedOptions, String accessToken) async {
    final availableSpotifyArtists = UniqueNamedEntitySet<ImportedArtist>();

    if (selectedOptions[SpotifyImportOption.topArtists] == true) {
      availableSpotifyArtists.addAll(await getTopArtists(accessToken, 50, 0));
    }

    if (selectedOptions[SpotifyImportOption.followedArtists] == true) {
      availableSpotifyArtists.addAll(await getFollowedArtists(accessToken));
    }

    return availableSpotifyArtists;
  }

  void _mapConfirmArtistsForSpotifyImportEventToState(
      ConfirmArtistsForSpotifyImport event, Emitter<SpotifyImportState> emit) {
    if (event.selectedArtists.isEmpty) {
      errorStreamController.add(InvalidUserInputException("No artists selected for import."));
    } else {
      final availableGenresForSelectedArtists = _getAvailableGenresForSelectedArtists(event.selectedArtists);
      emit(state.copyWith(
          selectedArtists: event.selectedArtists,
          availableGenresForSelectedArtists: availableGenresForSelectedArtists,
          step: _getNextFlowStep(state)));
    }
  }

  UniqueNamedEntitySet<ImportedGenre> _getAvailableGenresForSelectedArtists(List<ImportedArtist> selectedArtists) {
    final UniqueNamedEntitySet<ImportedGenre> availableGenresForSelectedArtists = UniqueNamedEntitySet();
    selectedArtists.forEach((artist) {
      List<ImportedGenre> genresList = artist.genres.map((genreName) => ImportedGenre(genreName)).toList();
      genresList.forEach((genreEntity) => availableGenresForSelectedArtists.add(genreEntity));
    });
    return availableGenresForSelectedArtists;
  }

  void _mapConfirmGenreTagsForSpotifyImportEventToState(
      ConfirmGenreTagsForSpotifyImport event, Emitter<SpotifyImportState> emit) {
    if (state.availableGenresForSelectedArtists == null) {
      errorStreamController.add(UnknownError("Something went wrong: Genres are not available for import."));
    } else if (event.selectedGenres.isEmpty && state.availableGenresForSelectedArtists!.isEmpty == false) {
      errorStreamController.add(InvalidUserInputException("No genres selected for import."));
    } else {
      emit(state.copyWith(selectedGenres: event.selectedGenres, step: _getNextFlowStep(state)));
    }
  }

  void _mapCompleteSpotifyImportEventToState(CompleteSpotifyImport event, Emitter<SpotifyImportState> emit) async {
    final Map<ImportSubProcess, DbRequestSuccessCounter> successCounters =
        await _spotifyImportProcessor.conductImport(event.selectedArtists, event.selectedGenres, _repository);
    final resultMessage = _getResultMessage(successCounters);
    errorStreamController.add(UserInfo(resultMessage));

    emit(state.copyWith(step: SpotifyImportFlowStep.finished));
  }

  SpotifyImportFlowStep _getNextFlowStep(SpotifyImportState currentState) {
    if (currentState.step == SpotifyImportFlowStep.artistsSelection && !currentState.doImportGenres) {
      return SpotifyImportFlowStep.confirmation;
    }
    return SpotifyImportFlowStep.values[currentState.step.index + 1];
  }

  String _getResultMessage(Map<ImportSubProcess, DbRequestSuccessCounter> creationSuccessCountersByType) {
    String message;

    if (creationSuccessCountersByType[ImportSubProcess.createArtists] == null) {
      message = "No entities were added.";
    } else {
      final successfulArtists = creationSuccessCountersByType[ImportSubProcess.createArtists]?.successCount ?? 0;
      final successfulGenres = creationSuccessCountersByType[ImportSubProcess.createTags]?.successCount ?? 0;
      if (successfulArtists > 0) {
        if (successfulGenres > 0) {
          message = "Successfully added ${successfulArtists} artists and ${successfulGenres} tags.";
        } else {
          message = "Successfully added ${successfulArtists} artists.";
        }
      } else if (successfulGenres > 0) {
        message = "Successfully added ${successfulGenres} genres.";
      } else {
        message = "No entities were added.";
      }
    }

    return message;
  }
}
