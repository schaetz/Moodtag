import 'package:diacritic/diacritic.dart';
import 'package:moodtag/exceptions/database_error.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/exceptions/invalid_argument_exception.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class RepositoryHelper {
  final MoodtagDB _db;

  const RepositoryHelper(this._db);

  Future<DbRequestResponse> wrapExceptionsAndReturnResponse(Future changedEntityFuture) async {
    Exception? exception = null;
    await changedEntityFuture.onError<Exception>((e, stackTrace) {
      exception = e;
    });

    if (exception != null) {
      return new DbRequestResponse.fail(exception);
    }
    return new DbRequestResponse.success();
  }

  Future<DbRequestResponse<E>> wrapExceptionsAndReturnResponseWithCreatedEntity<E>(
      Future<int?> createEntityFuture, String name) async {
    try {
      E? newEntity = await createEntityFuture.then((newEntityId) async => await _getEntityById<E>(newEntityId));

      if (newEntity == null) {
        final exception = DatabaseError('The ID of the newly created entity could not be retrieved.');
        return new DbRequestResponse<E>.fail(exception, parameters: [name]);
      }
      return new DbRequestResponse<E>.success(changedEntity: newEntity, parameters: [name]);
    } on Exception catch (e) {
      return new DbRequestResponse<E>.fail(e, parameters: [name]);
    }
  }

  Future<E?> _getEntityById<E>(int? id) {
    if (id == null) {
      return Future.error(new InvalidArgumentException('getEntityById was called without a valid ID.'));
    }

    if (E == Artist) {
      return _db.getArtistByIdOnce(id) as Future<E?>;
    } else if (E == Tag) {
      return _db.getTagByIdOnce(id) as Future<E?>;
    } else {
      return Future.error(
          new InvalidArgumentException('getEntityById was called with an invalid entity type: ' + E.toString()));
    }
  }

  String getOrderingNameForArtist(String artistName) {
    final lowerCased = artistName.toLowerCase();
    final diacriticsReplaced = removeDiacritics(lowerCased);
    final leadingTheRemoved = diacriticsReplaced.replaceFirst(RegExp('^the\\s'), '');
    print("$artistName => $leadingTheRemoved");
    return leadingTheRemoved;
  }
}
