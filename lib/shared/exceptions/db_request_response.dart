import 'package:drift/native.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/exceptions/user_readable/database_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/name_already_taken_exception.dart';
import 'package:moodtag/shared/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/shared/exceptions/user_readable/user_readable_exception.dart';

class DbRequestResponse<E> {
  // Sqlite extended result codes: see https://www.sqlite.org/rescode.html
  static final int sqliteConstraintPrimaryKey = 1555;
  static final int sqliteConstraintUnique = 2067;

  late final E? changedEntity;
  late final List<Object>? parameters;
  late final Exception? exception;

  DbRequestResponse.success({this.changedEntity, this.parameters, this.exception = null});
  DbRequestResponse.fail(this.exception, {this.changedEntity = null, this.parameters});
  DbRequestResponse(this.changedEntity, this.exception);

  bool didSucceed() {
    return changedEntity != null && exception == null;
  }

  bool didFail() {
    return exception != null;
  }

  bool isSqliteException() {
    return exception != null && exception is SqliteException;
  }

  bool isSqliteExceptionWithErrorCode(int extendedResultCode) {
    return getSqliteException()?.extendedResultCode == extendedResultCode;
  }

  SqliteException? getSqliteException() {
    if (isSqliteException()) {
      return exception as SqliteException;
    }
    return null;
  }

  UserReadableException getUserFeedbackException() {
    if (isSqliteException()) {
      if (isSqliteExceptionWithErrorCode(sqliteConstraintUnique)) {
        String? alreadyExistingName = _getStringParameter(0);
        String anEntityDenotation = 'an entity';
        if (E == Artist) {
          anEntityDenotation = 'an artist';
        } else if (E == Tag) {
          anEntityDenotation = 'a tag';
        }
        final message = alreadyExistingName != null
            ? 'There is already $anEntityDenotation with the name "$alreadyExistingName".'
            : 'There is already $anEntityDenotation with the same name.';
        return new NameAlreadyTakenException(message, cause: exception);
      }
      return new DatabaseError('A database error occurred.', cause: exception);
    } else {
      return new UnknownError('An unknown error occurred.', cause: exception);
    }
  }

  String? _getStringParameter(int index) {
    if (parameters != null && parameters!.length >= index + 1 && parameters![index] is String) {
      return parameters![index] as String;
    }
    return null;
  }
}

UserReadableException? getHighestSeverityExceptionForMultipleResponses(List<DbRequestResponse> exceptionResponses) {
  final userReadableExceptions = exceptionResponses.map((response) => response.getUserFeedbackException()).toList();
  return getHighestSeverityException(userReadableExceptions);
}

UserReadableException? getHighestSeverityException(List<UserReadableException> userReadableExceptions) {
  ExceptionSeverity highestSeverity = ExceptionSeverity.LOW;
  UserReadableException? highestSeverityException;

  for (UserReadableException exception in userReadableExceptions) {
    if (highestSeverityException == null || exception.severity.index > highestSeverity.index) {
      highestSeverityException = exception;
      highestSeverity = exception.severity;
    }
  }

  return highestSeverityException;
}
