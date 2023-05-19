import 'loading_status.dart';

class LoadedData<T> {
  late final T? data;
  late final LoadingStatus loadingStatus;

  LoadedData(this.data, {this.loadingStatus = LoadingStatus.initial});

  LoadedData.initial() {
    this.data = null;
    this.loadingStatus = LoadingStatus.initial;
  }

  LoadedData.loading() {
    this.data = null;
    this.loadingStatus = LoadingStatus.loading;
  }

  LoadedData.success(this.data) {
    this.loadingStatus = LoadingStatus.success;
  }

  LoadedData.error() {
    this.data = null;
    this.loadingStatus = LoadingStatus.error;
  }
}
