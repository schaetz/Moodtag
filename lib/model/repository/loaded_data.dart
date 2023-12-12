import 'package:equatable/equatable.dart';

import 'loading_status.dart';

class LoadedData<T> extends Equatable {
  final T? data;
  final LoadingStatus loadingStatus;
  final String? errorMessage;

  LoadedData(this.data, {this.loadingStatus = LoadingStatus.initial, this.errorMessage = null});

  const LoadedData.initial()
      : this.data = null,
        this.loadingStatus = LoadingStatus.initial,
        this.errorMessage = null;

  const LoadedData.loading()
      : this.data = null,
        this.loadingStatus = LoadingStatus.loading,
        this.errorMessage = null;

  const LoadedData.success(this.data)
      : this.loadingStatus = LoadingStatus.success,
        this.errorMessage = null;

  const LoadedData.error({String? message})
      : this.data = null,
        this.loadingStatus = LoadingStatus.error,
        this.errorMessage = message;

  @override
  List<Object?> get props => [data, loadingStatus, errorMessage];

  LoadedData<T> copyWith({T? data, LoadingStatus? loadingStatus, String? errorMessage}) {
    return LoadedData<T>(
      data ?? this.data,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
