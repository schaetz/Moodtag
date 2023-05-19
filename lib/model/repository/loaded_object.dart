import 'loading_status.dart';

class LoadedObject<T> {
  late final T? obj;
  late final LoadingStatus loadingStatus;

  LoadedObject(this.obj, {this.loadingStatus = LoadingStatus.initial});

  LoadedObject.initial() {
    this.obj = null;
    this.loadingStatus = LoadingStatus.initial;
  }

  LoadedObject.loading() {
    this.obj = null;
    this.loadingStatus = LoadingStatus.loading;
  }

  LoadedObject.success(this.obj) {
    this.loadingStatus = LoadingStatus.success;
  }

  LoadedObject.error() {
    this.obj = null;
    this.loadingStatus = LoadingStatus.error;
  }
}
