import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_object.dart';

abstract class EntityLoaderUserState<S extends EntityLoaderUserState<S>> extends Equatable {
  final LoadedObject<List<ArtistData>>? allArtistsWithTags;
  final LoadedObject<List<TagData>>? allTags;

  EntityLoaderUserState({required this.allArtistsWithTags, required this.allTags});

  @override
  List<Object?> get props;

  S copyWith({LoadedObject<List<ArtistData>>? allArtistsWithTags, LoadedObject<List<TagData>>? allTags});

  S updateAllArtists(LoadedObject<List<ArtistData>>? allArtistsWithTags) {
    return copyWith(allArtistsWithTags: allArtistsWithTags);
  }

  S updateAllTags(LoadedObject<List<TagData>>? allTags) {
    return copyWith(allTags: allTags);
  }
}
