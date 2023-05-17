import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

import 'library_events.dart';

abstract class ArtistEvent extends LibraryEvent {
  const ArtistEvent();
}

class ArtistUpdated extends ArtistEvent {
  final Artist? artist;
  final Object? error;

  const ArtistUpdated({this.artist, this.error});

  @override
  List<Object?> get props => [artist, error];
}

class ArtistsListUpdated extends ArtistEvent {
  final List<ArtistWithTags>? artistsWithTags;
  final Object? error;

  const ArtistsListUpdated({this.artistsWithTags, this.error});

  @override
  List<Object?> get props => [artistsWithTags, error];
}

class ArtistsListPlusUpdated extends ArtistEvent {
  final List<ArtistWithTagFlag>? artistWithTagFlag;
  final Object? error;

  const ArtistsListPlusUpdated({this.artistWithTagFlag, this.error});

  @override
  List<Object?> get props => [artistWithTagFlag, error];
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
