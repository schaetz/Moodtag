import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_object.dart';

class EntityLoaderState extends Equatable {
  late final LoadedData<ArtistsList> loadedDataAllArtists;
  late final LoadedData<TagsList> loadedDataAllTags;

  EntityLoaderState({
    required this.loadedDataAllArtists,
    required this.loadedDataAllTags,
  });

  EntityLoaderState.initial() {
    this.loadedDataAllArtists = LoadedData.initial();
    this.loadedDataAllTags = LoadedData.initial();
  }

  @override
  List<Object> get props => [loadedDataAllArtists, loadedDataAllTags];

  EntityLoaderState copyWith({
    LoadedData<ArtistsList>? allArtistsWithTags,
    LoadedData<TagsList>? allTags,
  }) {
    return EntityLoaderState(
      loadedDataAllArtists: allArtistsWithTags ?? this.loadedDataAllArtists,
      loadedDataAllTags: allTags ?? this.loadedDataAllTags,
    );
  }
}
