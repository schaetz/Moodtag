import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
}

class ResetLibrary extends LibraryEvent {
  @override
  List<Object?> get props => [];
}
