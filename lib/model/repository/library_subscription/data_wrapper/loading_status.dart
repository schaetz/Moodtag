enum LoadingStatus { initial, success, error, loading }

extension LoadingStatusX on LoadingStatus {
  bool get isInitial => this == LoadingStatus.initial;
  bool get isSuccess => this == LoadingStatus.success;
  bool get isError => this == LoadingStatus.error;
  bool get isLoading => this == LoadingStatus.loading;
  bool get isInitialOrLoading => this == LoadingStatus.initial || this == LoadingStatus.loading;

  LoadingStatus merge(LoadingStatus other) {
    if (this.isError || other.isError) {
      return LoadingStatus.error;
    } else if (this.isSuccess && other.isSuccess) {
      return LoadingStatus.success;
    } else if (this.isInitial && other.isInitial) {
      return LoadingStatus.initial;
    }
    return LoadingStatus.loading;
  }
}
