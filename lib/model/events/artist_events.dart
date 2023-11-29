import 'package:moodtag/model/database/moodtag_db.dart';

import 'library_events.dart';

abstract class ArtistEvent extends LibraryEvent {
  const ArtistEvent();
}

class ChangeArtistsListFilters extends ArtistEvent {
  final Set<Tag> filterTags;

  const ChangeArtistsListFilters({required this.filterTags});

  @override
  List<Object> get props => [filterTags];
}

class CreateArtists extends ArtistEvent {
  final String input;

  const CreateArtists(this.input);

  @override
  List<Object> get props => [input];
}

class DeleteArtist extends ArtistEvent {
  final Artist artist;

  const DeleteArtist(this.artist);

  @override
  List<Object> get props => [artist];
}

class RemoveTagFromArtist extends ArtistEvent {
  final Artist artist;
  final Tag tag;

  const RemoveTagFromArtist(this.artist, this.tag);

  @override
  List<Object> get props => [artist, tag];
}

class ToggleTagEditMode extends ArtistEvent {
  @override
  List<Object> get props => [];
}

class ToggleTagForArtist extends ArtistEvent {
  final Artist artist;
  final Tag tag;

  const ToggleTagForArtist(this.artist, this.tag);

  @override
  List<Object> get props => [artist, tag];
}

class ToggleSearchBar extends ArtistEvent {
  @override
  List<Object> get props => [];
}

class ChangeSearchItem extends ArtistEvent {
  final String searchItem;

  ChangeSearchItem(this.searchItem);

  @override
  List<Object> get props => [searchItem];
}

class ToggleTagSubtitles extends ArtistEvent {
  @override
  List<Object> get props => [];
}

class ToggleFilterSelectionModal extends ArtistEvent {
  final bool? wantedOpen;

  ToggleFilterSelectionModal({this.wantedOpen});

  @override
  List<Object?> get props => [wantedOpen];
}

class FilterSelectionModalStateChanged extends ArtistEvent {
  final bool open;

  FilterSelectionModalStateChanged({required this.open});

  @override
  List<Object> get props => [open];
}
