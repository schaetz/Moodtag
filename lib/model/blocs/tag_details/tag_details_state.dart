import 'package:equatable/equatable.dart';
import 'package:moodtag/model/blocs/library_user/library_user_state_interface.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class TagDetailsState extends Equatable implements ILibraryUserState {
  final int tagId;
  final LoadedData<TagData> loadedTagData;
  final LoadedData<ArtistsList> loadedDataAllArtists;
  final bool checklistMode;

  // deduced properties
  // TODO Where do we get this from?
  late final LoadedData<List<ArtistData>> artistsWithThisTagOnly;

  @override
  LoadedData<ArtistsList>? get allArtistsData => loadedDataAllArtists;

  @override
  LoadedData<TagsList>? get allTagsData => null;

  TagDetailsState(
      {this.loadedDataAllArtists = const LoadedData.initial(),
      required this.tagId,
      this.loadedTagData = const LoadedData.initial(),
      this.checklistMode = false,
      this.artistsWithThisTagOnly = const LoadedData.initial()});

  @override
  List<Object> get props => [tagId, loadedTagData, loadedDataAllArtists, checklistMode];

  TagDetailsState copyWith(
      {int? tagId,
      LoadedData<TagData>? loadedTagData,
      LoadedData<ArtistsList>? loadedDataAllArtists,
      LoadedData<TagsList>? loadedDataAllTags, // not used
      bool? checklistMode}) {
    return TagDetailsState(
        tagId: tagId ?? this.tagId,
        loadedTagData: loadedTagData ?? this.loadedTagData,
        loadedDataAllArtists: loadedDataAllArtists ?? this.loadedDataAllArtists,
        checklistMode: checklistMode ?? this.checklistMode);
  }
}
