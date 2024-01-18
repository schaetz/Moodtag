import 'dart:async';

import 'package:drift/drift.dart';

import '../join_data_classes.dart';
import '../moodtag_db.dart';

typedef ArtistDataOpt = ArtistData?;

/**
 *  Transformer to transform raw SQL results with pairs of artists and joined tags (containing redundancy)
 *  to ArtistData / ArtistsList objects; The results can be filtered by tags.
 *  It is important to filter by tag IDs rather than the Tag objects themselves, as other properties of Tag
 *  such as category may have changed since setting up the subscription and may lead to false inequality.
 */
// Result type is either ArtistData or ArtistsList (= List<ArtistData>)
class ArtistsWithTagTransformer<ResultType> implements StreamTransformer<List<TypedResult>, ResultType> {
  final MoodtagDB _moodtagDB;
  final Set<int>? filterTagIds;

  StreamController<ResultType> _controller = StreamController();
  Map<Artist, ArtistData> artistToEnhancedArtistMap = {};

  ArtistsWithTagTransformer(this._moodtagDB, {this.filterTagIds});

  @override
  Stream<ResultType> bind(Stream<List<TypedResult>> stream) {
    stream.listen((List<TypedResult> typedResults) {
      artistToEnhancedArtistMap = {};
      typedResults.forEach((queryResult) {
        final artist = queryResult.readTable(_moodtagDB.artists);
        final tag = queryResult.readTableOrNull(_moodtagDB.tags);
        // Create new ArtistData object or get the existing one for artist
        final artistWithTags = artistToEnhancedArtistMap.putIfAbsent(artist, () => ArtistData(artist, Set<Tag>()));
        if (tag != null) {
          artistWithTags.tags.add(tag);
        }
      });

      if (filterTagIds != null && filterTagIds!.isNotEmpty) {
        artistToEnhancedArtistMap.removeWhere((artist, artistWithTags) =>
            artistWithTags.tags.map((tag) => tag.id).toSet().intersection(filterTagIds!).isEmpty);
      }

      if (ResultType == ArtistData || ResultType == ArtistDataOpt) {
        if (artistToEnhancedArtistMap.values.isNotEmpty) {
          _controller.add(artistToEnhancedArtistMap.values.first as ResultType);
        }
      } else if (ResultType == ArtistsList) {
        _controller.add(artistToEnhancedArtistMap.values.toList() as ResultType);
      }
    });
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
