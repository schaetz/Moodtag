import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

abstract class ArtistEvent extends Equatable {
  const ArtistEvent();
}

class GetSelectedArtist extends ArtistEvent {
  final int id;

  const GetSelectedArtist(this.id);

  @override
  List<Object> get props => [];
}

class GetArtists extends ArtistEvent {
  @override
  List<Object> get props => [];
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
