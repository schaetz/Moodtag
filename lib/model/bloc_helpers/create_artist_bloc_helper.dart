import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/utils/helpers.dart';

class CreateArtistBlocHelper {
  void handleCreateArtistEvent(CreateArtists event, Repository repository) async {
    List<String> inputElements = processMultilineInput(event.input);
    List<DbRequestResponse> exceptionResponses = [];

    for (String newArtistName in inputElements) {
      final createArtistResponse = await repository.createArtist(newArtistName);
      if (createArtistResponse.didFail()) exceptionResponses.add(createArtistResponse);
    }

    //TODO handle exceptions
  }
}
