import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_object.dart';
import 'package:moodtag/model/repository/loading_status.dart';

abstract class AbstractEntityUserState extends Equatable {
  final LoadedData<ArtistsList>? loadedDataAllArtists;
  final LoadedData<TagsList>? loadedDataAllTags;

  AbstractEntityUserState({this.loadedDataAllArtists, this.loadedDataAllTags});

  ArtistsList? get allArtistsWithTags => loadedDataAllArtists?.data;
  TagsList? get allTags => loadedDataAllTags?.data;

  bool get isArtistsListLoaded => loadedDataAllArtists?.loadingStatus == LoadingStatus.success;
  bool get isTagsListLoaded => loadedDataAllTags?.loadingStatus == LoadingStatus.success;

  @override
  List<Object?> get props;

  AbstractEntityUserState copyWith(
      {LoadedData<ArtistsList>? loadedDataAllArtists, LoadedData<TagsList>? loadedDataAllTags});
}
