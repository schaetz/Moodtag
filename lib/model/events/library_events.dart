import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
}

class ResetLibrary extends LibraryEvent {
  @override
  List<Object?> get props => [];
}

class StartedLoading extends LibraryEvent {
  final Type loadedType;

  StartedLoading(this.loadedType);

  @override
  List<Object> get props => [loadedType];
}
