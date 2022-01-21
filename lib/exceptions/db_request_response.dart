import 'package:drift/native.dart';

import 'package:moodtag/exceptions/database_error.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/exceptions/unknown_error.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';

class DbRequestResponse<E> {

  E changedEntity;
  List<Object> parameters;
  Exception exception;

  DbRequestResponse.success(this.changedEntity, parameters);
  DbRequestResponse.fail(this.exception, parameters);
  DbRequestResponse(this.changedEntity, this.exception);

  DbRequestResponse.exceptionFrom(DbRequestResponse otherRequestResponse) {
    this.exception = otherRequestResponse.exception;
  }

  bool didSucceed() {
    return changedEntity != null && exception == null;
  }

  bool didFail() {
    return exception != null;
  }

  bool isSqliteException() {
    return exception != null && exception is SqliteException;
  }

  SqliteException getSqliteException() {
    if (isSqliteException()) {
      return exception as SqliteException;
    }
    return null;
  }

  UserReadableException getUserFeedbackException() {
    if (isSqliteException()) {
      if (getSqliteException().extendedResultCode == 2067) {
        String alreadyExistingName = _getStringParameter(0);
        final message = alreadyExistingName != null
            ? 'There is already an entity with the name $alreadyExistingName.'
            : 'There is already an entity with the same name.';
        return new NameAlreadyTakenException(message);
      }
      return new DatabaseError('A database error occurred.');
    } else {
      return new UnknownError('An unknown error occurred.');
    }
  }

  String _getStringParameter(int index) {
    if (parameters != null && parameters.length >= index+1 && parameters[index] is String) {
      return parameters[index] as String;
    }
    return null;
  }

}

UserReadableException getHighestSeverityExceptionForMultipleResponses(List<DbRequestResponse> exceptionResponses) {
  ExceptionSeverity highestSeverity = ExceptionSeverity.LOW;
  UserReadableException highestSeverityException;

  for (DbRequestResponse response in exceptionResponses) {
    UserReadableException userFeedbackException = response.getUserFeedbackException();

    if (highestSeverityException == null || userFeedbackException.severity.index > highestSeverity.index) {
      highestSeverityException = userFeedbackException;
      highestSeverity = userFeedbackException.severity;
    }
  }

  return highestSeverityException;
}