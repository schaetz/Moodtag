import 'package:moodtag/model/blocs/entity_loader/abstract_entity_user_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class TagDetailsState extends AbstractEntityUserState {
  final int tagId;
  final LoadedData<TagData> loadedTagData;
  final bool checklistMode;

  // deduced properties
  late final LoadedData<List<ArtistData>> artistsWithThisTagOnly;

  TagDetailsState(
      {required LoadedData<ArtistsList> loadedDataAllArtists,
      required this.tagId,
      this.loadedTagData = const LoadedData.initial(),
      required this.checklistMode})
      : super(loadedDataAllArtists: loadedDataAllArtists) {
    artistsWithThisTagOnly = _determineArtistsWithTagOnlyIfPossible();
  }

  LoadedData<List<ArtistData>> _determineArtistsWithTagOnlyIfPossible() {
    if (loadedTagData.loadingStatus.isSuccess && loadedDataAllArtists.loadingStatus.isSuccess) {
      return LoadedData.success(
          loadedDataAllArtists.data!.where((artist) => artist.tags.contains(loadedTagData.data?.tag)).toList());
    } else if (loadedTagData.loadingStatus.isError || loadedDataAllArtists.loadingStatus.isError) {
      return LoadedData.error();
    }
    return LoadedData.loading();
  }

  @override
  List<Object> get props => [loadedDataAllArtists, tagId, loadedTagData, checklistMode, artistsWithThisTagOnly];

  TagDetailsState copyWith(
      {LoadedData<ArtistsList>? loadedDataAllArtists,
      LoadedData<TagsList>? loadedDataAllTags, // not used, but required by interface
      int? tagId,
      LoadedData<TagData>? loadedTagData,
      bool? checklistMode}) {
    return TagDetailsState(
        loadedDataAllArtists: loadedDataAllArtists ?? this.loadedDataAllArtists,
        tagId: tagId ?? this.tagId,
        loadedTagData: loadedTagData ?? this.loadedTagData,
        checklistMode: checklistMode ?? this.checklistMode);
  }
}
