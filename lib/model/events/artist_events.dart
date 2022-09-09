import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

abstract class ArtistEvent extends Equatable {
  const ArtistEvent();
}

class GetArtists extends ArtistEvent {
  @override
  List<Object> get props => [];
}

class CreateArtist extends ArtistEvent {
  final String name;

  CreateArtist(this.name);

  @override
  List<Object> get props => [name];
}

class DeleteArtist extends ArtistEvent {
  final Artist artist;

  DeleteArtist(this.artist);

  @override
  List<Object> get props => [artist];
}
