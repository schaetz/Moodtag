import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

class ArtistsListState {
  final LoadedData<ArtistsList> loadedDataFilteredArtists;
  final bool displayTagSubtitles;
  final Set<Tag> filterTags;

  ArtistsListState({
    this.loadedDataFilteredArtists = const LoadedData.initial(),
    this.displayTagSubtitles = false,
    this.filterTags = const {},
  });

  List<Object> get props => [loadedDataFilteredArtists, displayTagSubtitles, filterTags];

  ArtistsListState copyWith({
    LoadedData<ArtistsList>? loadedDataFilteredArtists,
    bool? displayTagSubtitles,
    Set<Tag>? filterTags,
  }) {
    return ArtistsListState(
      loadedDataFilteredArtists: loadedDataFilteredArtists ?? this.loadedDataFilteredArtists,
      displayTagSubtitles: displayTagSubtitles ?? this.displayTagSubtitles,
      filterTags: filterTags != null ? filterTags : this.filterTags, // filterTags can be overridden by an empty set
    );
  }
}
