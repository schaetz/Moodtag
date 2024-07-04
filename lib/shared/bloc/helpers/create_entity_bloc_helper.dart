import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/helpers/entity_processing_helper.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/app_settings_events.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/exceptions/db_request_response.dart';
import 'package:moodtag/shared/exceptions/user_readable/database_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/invalid_user_input_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/user_readable_exception.dart';
import 'package:moodtag/shared/utils/helpers.dart';

class CreateEntityBlocHelper {
  Future<(List<BaseArtist>?, UserReadableException?)> handleCreateArtistsEvent(
      CreateArtists event, Repository repository) async {
    final List<String> inputElements = processMultilineInput(event.input);
    final List<DbRequestResponse> exceptionResponses = [];
    final List<BaseArtist> createdArtistEntities = [];

    for (String newArtistName in inputElements) {
      final createArtistResponse = await repository.createArtist(newArtistName);
      if (createArtistResponse.didFail()) exceptionResponses.add(createArtistResponse);

      if (createArtistResponse.changedEntity != null) {
        createdArtistEntities.add(createArtistResponse.changedEntity!);
      }
    }

    return (createdArtistEntities, getHighestSeverityExceptionForMultipleResponses(exceptionResponses));
  }

  Future<(List<BaseTag>?, UserReadableException?)> handleCreateTagsEvent(
      CreateTags event, Repository repository) async {
    final List<String> inputElements = processMultilineInput(event.input);
    final List<DbRequestResponse> exceptionResponses = [];
    final List<BaseTag> createdTagEntities = [];

    final defaultTagCategory = await repository.getDefaultTagCategoryOnce();
    if (defaultTagCategory == null) {
      return (null, DatabaseError('There is no default tag category that can be assigned.'));
    }

    for (String newTagName in inputElements) {
      final tagCategory = event.tagCategory ?? defaultTagCategory;
      final createTagResponse = await repository.createTag(newTagName, tagCategory);
      if (createTagResponse.didFail()) exceptionResponses.add(createTagResponse);

      if (createTagResponse.changedEntity != null) {
        createdTagEntities.add(createTagResponse.changedEntity!);
      }

      if (event.preselectedArtist != null &&
          createTagResponse.didSucceed() &&
          createTagResponse.changedEntity != null) {
        final assignTagToArtistResponse =
            await repository.assignTagToArtist(event.preselectedArtist!, createTagResponse.changedEntity!);
        if (assignTagToArtistResponse.didFail()) exceptionResponses.add(assignTagToArtistResponse);
      }
    }

    return (createdTagEntities, getHighestSeverityExceptionForMultipleResponses(exceptionResponses));
  }

  Future<UserReadableException?> handleChangeCategoryForTagEvent(
      ChangeCategoryForTag changeCategoryForTag, Repository repository) async {
    final response = await repository.changeCategoryForTag(changeCategoryForTag.tag, changeCategoryForTag.tagCategory);
    if (response.didFail()) {
      return response.getUserFeedbackException();
    }

    return Future.value(null);
  }

  Future<UserReadableException?> handleAddArtistsForTagEvent(AddArtistsForTag event, Repository repository) async {
    List<String> inputElements = processMultilineInput(event.input);
    List<UserReadableException> exceptions = [];

    final artistNameToObjectMap = await getMapFromArtistNameToBaseArtistObject(repository);

    for (String artistName in inputElements) {
      // create artist if not existing
      if (!artistNameToObjectMap.containsKey(artistName)) {
        final DbRequestResponse<BaseArtist> createArtistResponse = await repository.createArtist(artistName);
        if (createArtistResponse.didSucceed()) {
          artistNameToObjectMap[artistName] = createArtistResponse.changedEntity!;
        }
        if (createArtistResponse.didFail()) exceptions.add(createArtistResponse.getUserFeedbackException());
      }

      // assign artist to tag
      if (artistNameToObjectMap.containsKey(artistName)) {
        final assignTagToArtistResponse =
            await repository.assignTagToArtist(artistNameToObjectMap[artistName]!, event.tag);
        if (assignTagToArtistResponse.didFail()) {
          if (assignTagToArtistResponse.isSqliteExceptionWithErrorCode(DbRequestResponse.sqliteConstraintPrimaryKey)) {
            return InvalidUserInputException(
                'The tag "${event.tag.name}" is already assigned to the artist "${artistName}".');
          }
          return assignTagToArtistResponse.getUserFeedbackException();
        }
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

  Future<UserReadableException?> handleCreateTagCategoryEvent(CreateTagCategory event, Repository repository) async {
    final createTagCategoryResponse = await repository.createTagCategory(event.name, color: event.color.value);
    if (createTagCategoryResponse.didFail()) {
      return createTagCategoryResponse.getUserFeedbackException();
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

  Future<UserReadableException?> _addTagToArtist(BaseArtist artist, BaseTag tag, Repository repository) async {
    final assignTagResponse = await repository.assignTagToArtist(artist, tag);
    if (assignTagResponse.didFail()) {
      if (assignTagResponse.isSqliteExceptionWithErrorCode(DbRequestResponse.sqliteConstraintPrimaryKey)) {
        return InvalidUserInputException('The artist "${artist.name}" already has the tag ${tag.name}.');
      }
      return assignTagResponse.getUserFeedbackException();
    }

    return Future.value(null);
  }

  Future<UserReadableException?> _removeTagFromArtist(BaseArtist artist, BaseTag tag, Repository repository) async {
    final removeTagResponse = await repository.removeTagFromArtist(artist, tag);
    if (removeTagResponse.didFail()) {
      return removeTagResponse.getUserFeedbackException();
    }

    return Future.value(null);
  }
}
