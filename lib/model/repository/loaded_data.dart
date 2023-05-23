import 'loading_status.dart';

class LoadedData<T> {
  final T? data;
  final LoadingStatus loadingStatus;

  LoadedData(this.data, {this.loadingStatus = LoadingStatus.initial});

  const LoadedData.initial()
      : this.data = null,
        this.loadingStatus = LoadingStatus.initial;

  const LoadedData.loading()
      : this.data = null,
        this.loadingStatus = LoadingStatus.loading;

  const LoadedData.success(this.data) : this.loadingStatus = LoadingStatus.success;

  const LoadedData.error()
      : this.data = null,
        this.loadingStatus = LoadingStatus.error;
}
