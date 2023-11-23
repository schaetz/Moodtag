import 'package:moodtag/exceptions/db_request_response.dart';

class DbRequestSuccessCounter {
  int _totalCount = 0;
  int _successCount = 0;
  int _failureCount = 0;

  int get totalCount => _totalCount;
  int get successCount => _successCount;
  int get failureCount => _failureCount;

  DbRequestSuccessCounter();
  DbRequestSuccessCounter.instantiate(this._totalCount, this._successCount, this._failureCount);

  void registerResponse(DbRequestResponse response) {
    _totalCount++;
    if (response.didSucceed()) {
      _successCount++;
    } else {
      _failureCount++;
    }
  }
}
