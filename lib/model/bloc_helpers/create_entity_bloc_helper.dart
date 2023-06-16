import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/exceptions/unknown_error.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/entity_processing_helper.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/utils/helpers.dart';

class CreateEntityBlocHelper {
  Future<UserReadableException?> handleCreateArtistsEvent(CreateArtists event, Repository repository) async {
    List<String> inputElements = processMultilineInput(event.input);
    List<DbRequestResponse> exceptionResponses = [];

    for (String newArtistName in inputElements) {
      final createArtistResponse = await repository.createArtist(newArtistName);
      if (createArtistResponse.didFail()) exceptionResponses.add(createArtistResponse);
    }

    return getHighestSeverityExceptionForMultipleResponses(exceptionResponses);
  }

  Future<UserReadableException?> handleCreateTagsEvent(CreateTags event, Repository repository) async {
    List<String> inputElements = processMultilineInput(event.input);
    List<DbRequestResponse> exceptionResponses = [];

    for (String newTagName in inputElements) {
      final createTagResponse = await repository.createTag(newTagName);
      if (createTagResponse.didFail()) exceptionResponses.add(createTagResponse);

      if (event.preselectedArtist != null &&
          createTagResponse.didSucceed() &&
          createTagResponse.changedEntity != null) {
        final assignTagToArtistResponse =
            await repository.assignTagToArtist(event.preselectedArtist!, createTagResponse.changedEntity!);
        if (assignTagToArtistResponse.didFail()) exceptionResponses.add(assignTagToArtistResponse);
      }
    }

    return getHighestSeverityExceptionForMultipleResponses(exceptionResponses);
  }

  Future<UserReadableException?> handleAddArtistsForTagEvent(AddArtistsForTag event, Repository repository) async {
    List<String> inputElements = processMultilineInput(event.input);
    List<UserReadableException> exceptions = [];

    final artistNameToObjectMap = await getMapFromArtistNameToObject(repository);

    for (String artistName in inputElements) {
      if (!artistNameToObjectMap.containsKey(artistName)) {
        final DbRequestResponse<Artist> createArtistResponse = await repository.createArtist(artistName);
        if (createArtistResponse.didSucceed()) {
          artistNameToObjectMap[artistName] = createArtistResponse.changedEntity!;
        }
        if (createArtistResponse.didFail()) exceptions.add(createArtistResponse.getUserFeedbackException());
      }

      if (artistNameToObjectMap.containsKey(artistName)) {
        final assignTagToArtistResponse =
            await repository.assignTagToArtist(artistNameToObjectMap[artistName]!, event.tag);
        if (assignTagToArtistResponse.didFail()) exceptions.add(assignTagToArtistResponse.getUserFeedbackException());
      } else {
        exceptions.add(UnknownError("The tag could not be assigned to the artist ${artistName}."));
      }
    }

    return getHighestSeverityException(exceptions);
  }

  Future<UserReadableException?> handleToggleTagForArtistEvent(ToggleTagForArtist event, Repository repository) async {
    bool isTagAssignedToArtist = await repository.doesArtistHaveTag(event.artist, event.tag);
    if (isTagAssignedToArtist) {
      return await _removeTagFromArtist(event.artist, event.tag, repository);
    } else {
      return await _addTagToArtist(event.artist, event.tag, repository);
    }
  }

  Future<UserReadableException?> handleRemoveTagFromArtistEvent(
      RemoveTagFromArtist event, Repository repository) async {
    bool isTagAssignedToArtist = await repository.doesArtistHaveTag(event.artist, event.tag);
    if (isTagAssignedToArtist) {
      return await _removeTagFromArtist(event.artist, event.tag, repository);
    }

    return Future.value(null);
  }

  Future<UserReadableException?> handleCreateOrUpdateLastFmAccountEvent(
      LastFmAccount lastFmAccount, Repository repository) async {
    final createOrUpdateResponse = await repository.createOrUpdateLastFmAccount(lastFmAccount);
    if (createOrUpdateResponse.didFail()) {
      return createOrUpdateResponse.getUserFeedbackException();
    }

    return Future.value(null);
  }

  Future<UserReadableException?> handleRemoveLastFmAccount(Repository repository) async {
    final removeResponse = await repository.removeLastFmAccount();

    if (removeResponse.didFail()) {
      return removeResponse.getUserFeedbackException();
    }

    return Future.value(null);
  }

  Future<UserReadableException?> _addTagToArtist(Artist artist, Tag tag, Repository repository) async {
    final assignTagResponse = await repository.assignTagToArtist(artist, tag);
    if (assignTagResponse.didFail()) {
      return assignTagResponse.getUserFeedbackException();
    }

    return Future.value(null);
  }

  Future<UserReadableException?> _removeTagFromArtist(Artist artist, Tag tag, Repository repository) async {
    final removeTagResponse = await repository.removeTagFromArtist(artist, tag);
    if (removeTagResponse.didFail()) {
      return removeTagResponse.getUserFeedbackException();
    }

    return Future.value(null);
  }
}
