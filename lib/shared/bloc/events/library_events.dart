import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
}

class ResetLibrary extends LibraryEvent {
  @override
  List<Object?> get props => [];
}

class ActiveScreenChanged extends LibraryEvent {
  final bool isActive;

  ActiveScreenChanged(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

class ToggleSearchBar extends LibraryEvent {
  @override
  List<Object> get props => [];
}

class ChangeSearchItem extends LibraryEvent {
  final String searchItem;

  ChangeSearchItem(this.searchItem);

  @override
  List<Object> get props => [searchItem];
}

class ClearSearchItem extends LibraryEvent {
  @override
  List<Object> get props => [];
}
