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

class ToggleTagSubtitles extends ArtistEvent {
  @override
  List<Object> get props => [];
}

class ToggleFilterOverlay extends ArtistEvent {
  @override
  List<Object> get props => [];
}
