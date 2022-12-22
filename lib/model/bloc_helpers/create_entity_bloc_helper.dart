import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/utils/helpers.dart';

class CreateEntityBlocHelper {
  void handleCreateArtistsEvent(CreateArtists event, Repository repository) async {
    List<String> inputElements = processMultilineInput(event.input);
    List<DbRequestResponse> exceptionResponses = [];

    for (String newArtistName in inputElements) {
      final createArtistResponse = await repository.createArtist(newArtistName);
      if (createArtistResponse.didFail()) exceptionResponses.add(createArtistResponse);
    }

    //TODO handle exceptions
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

  void handleAssignTagToArtistEvent(AssignTagToArtist event, Repository repository) async {
    final assignTagToArtistResponse = await repository.assignTagToArtist(event.artist, event.tag);
    if (assignTagToArtistResponse.didFail()) {
      print(assignTagToArtistResponse.exception);
      // TODO handle exception
    }
  }
}
