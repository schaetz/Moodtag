class DbRequestResponse<E> {

  E changedEntity;
  Exception exception;

  DbRequestResponse.success(this.changedEntity);
  DbRequestResponse.fail(this.exception);
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

}