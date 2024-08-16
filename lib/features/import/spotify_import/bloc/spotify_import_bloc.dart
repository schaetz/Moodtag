import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/abstract_import_flow/bloc/abstract_import_bloc.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_access_token_provider.dart';
import 'package:moodtag/features/import/spotify_import/config/spotify_import_config.dart';
import 'package:moodtag/features/import/spotify_import/config/spotify_import_option.dart';
import 'package:moodtag/features/import/spotify_import/connectors/spotify_connector.dart';
import 'package:moodtag/features/import/spotify_import/connectors/spotify_import_processor.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/import_events.dart';
import 'package:moodtag/shared/bloc/events/spotify_import_events.dart';
import 'package:moodtag/shared/bloc/extensions/error_handling/error_stream_handling.dart';
import 'package:moodtag/shared/exceptions/user_readable/database_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/external_service_query_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/invalid_user_input_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/user_info.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/shared/models/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/shared/models/structs/imported_entities/unique_import_entity_set.dart';
import 'package:moodtag/shared/utils/db_request_success_counter.dart';
import 'package:moodtag/shared/utils/optional.dart';

import '../flow/spotify_import_flow_step.dart';
import 'spotify_import_state.dart';

class SpotifyImportBloc extends AbstractImportBloc<SpotifyImportState> with ErrorStreamHandling {
  final SpotifyImportProcessor _spotifyImportProcessor = SpotifyImportProcessor();

  final SpotifyAccessTokenProvider accessTokenProvider;

  SpotifyImportBloc(Repository repository, BuildContext mainContext, this.accessTokenProvider)
      : super(SpotifyImportState(), repository) {
    on<InitializeImport>(_handleInitializeImport);

    setupErrorHandler(mainContext);
  }

  @override
  Future<void> close() async {
    super.close();
    closeErrorStreamController();
  }

  void _handleInitializeImport(InitializeImport event, Emitter<SpotifyImportState> emit) async {
    on<ReturnToPreviousImportScreen>(_handleReturnToPreviousImportScreenEvent);
    on<ChangeImportConfig>(_handleChangeImportConfigEvent);
    on<ConfirmImportConfig>(_handleConfirmImportConfigEvent);
    on<ConfirmSpotifyArtistsForImport>(_handleConfirmSpotifyArtistsForImportEvent);
    on<ConfirmGenreTagsForImport>(_handleConfirmGenreTagsForImportEvent);
    on<CompleteSpotifyImport>(_handleCompleteImportEvent);

    final tagCategories = await repository.getTagCategoriesOnce();
    final tags = await repository.getTagsOnce();
    final initialImportConfig = _getInitialImportConfig(tagCategories);
    emit(state.copyWith(
        isInitialized: true,
        allTagCategories: LoadedData.success(tagCategories),
        allTags: LoadedData.success(tags),
        importConfig: initialImportConfig));
  }

  SpotifyImportConfig _getInitialImportConfig(List<TagCategory> tagCategories) {
    Map<SpotifyImportOption, bool> initialImportOptions = {};
    SpotifyImportOption.values.forEach((option) {
      initialImportOptions[option] = true;
    });

    final defaultTagCategory = tagCategories.first;
    return SpotifyImportConfig(categoryForTags: defaultTagCategory, options: initialImportOptions);
  }

  void _handleReturnToPreviousImportScreenEvent(ReturnToPreviousImportScreen event, Emitter<SpotifyImportState> emit) {
    if (state.step.index > SpotifyImportFlowStep.config.index) {
      emit(state.copyWith(step: SpotifyImportFlowStep.values[state.step.index - 1]));
    }
  }

  void _handleChangeImportConfigEvent(ChangeImportConfig event, Emitter<SpotifyImportState> emit) async {
    Optional<Map<SpotifyImportOption, bool>> importOptions = event.checkboxSelections.isPresent
        ? Optional({
            SpotifyImportOption.topArtists: event.checkboxSelections.content![SpotifyImportOption.topArtists] == true,
            SpotifyImportOption.followedArtists:
                event.checkboxSelections.content![SpotifyImportOption.followedArtists] == true,
            SpotifyImportOption.artistGenres:
                event.checkboxSelections.content![SpotifyImportOption.artistGenres] == true,
          })
        : Optional<Map<SpotifyImportOption, bool>>.none();

    final newImportConfig = state.importConfig!.copyWith(
        options: importOptions, categoryForTags: event.newTagCategory, initialTagForArtists: event.newInitialTag);
    emit(state.copyWith(importConfig: newImportConfig));
  }

  void _handleConfirmImportConfigEvent(ConfirmImportConfig event, Emitter<SpotifyImportState> emit) async {
    try {
      if (!state.isInitialized || state.importConfig == null) return;

      if (!state.importConfig!.isValid) {
        errorStreamController.add(InvalidUserInputException("Nothing selected for import."));
        return;
      }

      SpotifyAccessToken? accessToken = await accessTokenProvider.getAccessToken();
      if (accessToken == null) {
        errorStreamController.add(ExternalServiceQueryException('Authorization to Spotify Web API failed.'));
        return;
      }

      final availableSpotifyArtists = await _getAvailableSpotifyArtists(state.importConfig!, accessToken.token);

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

  Future<UniqueImportEntitySet<SpotifyArtist>> _getAvailableSpotifyArtists(
      SpotifyImportConfig importConfig, String accessToken) async {
    final availableSpotifyArtists = UniqueImportEntitySet<SpotifyArtist>();

    if (importConfig.options[SpotifyImportOption.topArtists] == true) {
      availableSpotifyArtists.addAll(await getTopArtists(accessToken, 50, 0));
    }

    if (importConfig.options[SpotifyImportOption.followedArtists] == true) {
      availableSpotifyArtists.addAll(await getFollowedArtists(accessToken));
    }

    if (!availableSpotifyArtists.isEmpty) {
      await annotateImportedArtistsWithAlreadyExistsProp(availableSpotifyArtists);
    }

    return availableSpotifyArtists;
  }

  void _handleConfirmSpotifyArtistsForImportEvent(
      ConfirmSpotifyArtistsForImport event, Emitter<SpotifyImportState> emit) async {
    if (event.selectedArtists.isEmpty) {
      errorStreamController.add(InvalidUserInputException("No artists selected for import."));
    } else {
      final defaultTagCategory = await repository.getDefaultTagCategoryOnce();
      if (defaultTagCategory == null) {
        errorStreamController.add(DatabaseError('There is no default tag category that can be assigned.'));
        return;
      }

      final availableGenresForSelectedArtists =
          await _getAvailableTagsForSelectedArtists(event.selectedArtists, defaultTagCategory);

      emit(state.copyWith(
          selectedArtists: event.selectedArtists,
          availableGenresForSelectedArtists: availableGenresForSelectedArtists,
          step: _getNextFlowStep(state)));
    }
  }

  Future<UniqueImportEntitySet<ImportedTag>> _getAvailableTagsForSelectedArtists(
      List<SpotifyArtist> selectedArtists, TagCategory tagCategory) async {
    final UniqueImportEntitySet<ImportedTag> tagsForSelectedArtists = UniqueImportEntitySet();
    selectedArtists.forEach((artist) {
      List<ImportedTag> tagsList = artist.tags.map((tagName) => ImportedTag(tagName, category: tagCategory)).toList();
      tagsList.forEach((genreEntity) => tagsForSelectedArtists.add(genreEntity));
    });

    if (!tagsForSelectedArtists.isEmpty) {
      await annotateImportedTagsWithAlreadyExistsProp(tagsForSelectedArtists);
    }

    return tagsForSelectedArtists;
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
    final successCounter =
        await _spotifyImportProcessor.conductImport(event.selectedArtists, event.selectedGenres, repository);

    // TODO Return more specific error message, not only including info on the result of the tag assignment
    errorStreamController.add(UserInfo(_getResultMessage(successCounter)));

    emit(state.copyWith(isFinished: true));
  }

  SpotifyImportFlowStep _getNextFlowStep(SpotifyImportState currentState) {
    if (currentState.step == SpotifyImportFlowStep.artistsSelection && !currentState.importConfig!.doImportGenres) {
      return SpotifyImportFlowStep.confirmation;
    }
    return SpotifyImportFlowStep.values[currentState.step.index + 1];
  }

  String _getResultMessage(DbRequestSuccessCounter successCounter) {
    if (successCounter.failureCount > 1) {
      return "Added ${successCounter.successCount} artists. There were some errors trying to assign the tags to the artists.";
    } else if (successCounter.failureCount == 1) {
      return "Added ${successCounter.successCount} artists. There was an error trying to assign the tags to the artists.";
    } else if (successCounter.successCount > 0) {
      return "Successfully added ${successCounter.successCount} artists";
    } else {
      return "Something went wrong. No artists were added.";
    }
  }
}
