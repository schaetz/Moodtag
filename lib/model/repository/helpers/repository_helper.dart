import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/exceptions/db_request_response.dart';
import 'package:moodtag/shared/exceptions/internal/invalid_argument_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/database_error.dart';

class RepositoryHelper {
  final Repository _repository;

  const RepositoryHelper(this._repository);

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

    if (E == BaseArtist) {
      return _repository.getBaseArtistByIdOnce(id) as Future<E?>;
    } else if (E == BaseTag) {
      return _repository.getBaseTagByIdOnce(id) as Future<E?>;
    } else if (E == TagCategory) {
      return _repository.getTagCategoryByIdOnce(id) as Future<E?>;
    } else if (E == LastFmAccount) {
      return _repository.getLastFmAccountOnce() as Future<E?>;
    } else {
      return Future.error(
          new InvalidArgumentException('getEntityById was called with an invalid entity type: ' + E.toString()));
    }
  }
}
