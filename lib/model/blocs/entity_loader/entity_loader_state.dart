import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_object.dart';

class EntityLoaderState extends Equatable {
  late final LoadedObject<List<ArtistData>> allArtistsWithTags;
  late final LoadedObject<List<TagData>> allTags;

  EntityLoaderState({
    required this.allArtistsWithTags,
    required this.allTags,
  });

  EntityLoaderState.initial() {
    this.allArtistsWithTags = LoadedObject.initial();
    this.allTags = LoadedObject.initial();
  }

  @override
  List<Object> get props => [allArtistsWithTags, allTags];

  EntityLoaderState copyWith({
    LoadedObject<List<ArtistData>>? allArtistsWithTags,
    LoadedObject<List<TagData>>? allTags,
  }) {
    return EntityLoaderState(
      allArtistsWithTags: allArtistsWithTags ?? this.allArtistsWithTags,
      allTags: allTags ?? this.allTags,
    );
  }
}
