import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
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

  void handleCreateTagsEvent(CreateTags event, Repository repository) async {
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

    //TODO handle exceptions
  }

  void handleToggleTagForArtistEvent(ToggleTagForArtist event, Repository repository) async {
    bool isTagAssignedToArtist = await repository.artistHasTag(event.artist, event.tag);
    if (isTagAssignedToArtist) {
      final removeTagFromArtistResponse = await repository.removeTagFromArtist(event.artist, event.tag);
      if (removeTagFromArtistResponse.didFail()) {
        print(removeTagFromArtistResponse.exception);
        // TODO handle exception
      }
    } else {
      final assignTagToArtistResponse = await repository.assignTagToArtist(event.artist, event.tag);
      if (assignTagToArtistResponse.didFail()) {
        print(assignTagToArtistResponse.exception);
        // TODO handle exception
      }
    }
  }

  // void showErrorInSnackbar(List<DbRequestResponse> exceptionResponses, bool preselectedOther) {
  //   UserReadableException? userFeedbackException = getHighestSeverityExceptionForMultipleResponses(exceptionResponses);
  //
  //   if (userFeedbackException == null) {
  //     // Ignore if there was no actual error (this should never happen)
  //     return;
  //   } else if (userFeedbackException is NameAlreadyTakenException && preselectedOther) {
  //     // Do not show an error message if the already existing entity
  //     // is assigned to a preselected other entity
  //     return;
  //   } else {
  //     final errorReason = userFeedbackException is NameAlreadyTakenException
  //         ? 'One or several $entityDenotationPlural already exist'
  //         : userFeedbackException.message;
  //     final errorMessage = 'Error while adding $entityDenotationPlural: $errorReason';
  //   }
  // }
}
