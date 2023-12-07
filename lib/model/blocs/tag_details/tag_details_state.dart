import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class TagDetailsState extends Equatable {
  final int tagId;
  final LoadedData<TagData> loadedTagData;
  final LoadedData<ArtistsList> loadedDataAllArtists;
  final bool checklistMode;

  // deduced properties
  late final LoadedData<List<ArtistData>> artistsWithThisTagOnly;

  TagDetailsState(
      {this.loadedDataAllArtists = const LoadedData.initial(),
      required this.tagId,
      this.loadedTagData = const LoadedData.initial(),
      this.checklistMode = false});

  @override
  List<Object> get props => [tagId, loadedTagData, loadedDataAllArtists, checklistMode];

  TagDetailsState copyWith(
      {int? tagId,
      LoadedData<TagData>? loadedTagData,
      LoadedData<ArtistsList>? loadedDataAllArtists,
      bool? checklistMode}) {
    return TagDetailsState(
        tagId: tagId ?? this.tagId,
        loadedTagData: loadedTagData ?? this.loadedTagData,
        loadedDataAllArtists: loadedDataAllArtists ?? this.loadedDataAllArtists,
        checklistMode: checklistMode ?? this.checklistMode);
  }
}
