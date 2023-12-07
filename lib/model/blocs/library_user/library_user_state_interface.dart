import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

abstract class ILibraryUserState {
  LoadedData<ArtistsList>? get allArtistsData;
  LoadedData<TagsList>? get allTagsData;

  ILibraryUserState copyWith({LoadedData<ArtistsList>? loadedDataAllArtists, LoadedData<TagsList>? loadedDataAllTags});
}
