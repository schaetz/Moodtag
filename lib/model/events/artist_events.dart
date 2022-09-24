import 'package:moodtag/model/database/moodtag_db.dart';

import 'LibraryEvent.dart';

abstract class ArtistEvent extends LibraryEvent {
  const ArtistEvent();
}

class ArtistUpdated extends ArtistEvent {
  final Artist artist;

  ArtistUpdated(this.artist);

  @override
  List<Object> get props => [artist];
}

class ArtistsListUpdated extends ArtistEvent {
  final List<Artist> artists;

  ArtistsListUpdated(this.artists);

  @override
  List<Object> get props => [artists];
}

class OpenCreateArtistDialog extends ArtistEvent {
  @override
  List<Object> get props => [];
}

class CloseCreateArtistDialog extends ArtistEvent {
  @override
  List<Object> get props => [];
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

class ToggleTagEditMode extends ArtistEvent {
  @override
  List<Object> get props => [];
}
