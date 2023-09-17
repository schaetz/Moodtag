import 'dart:async';

import 'package:drift/drift.dart';

import '../join_data_classes.dart';
import '../moodtag_db.dart';

typedef ArtistDataOpt = ArtistData?;

// Result type is either ArtistData or ArtistsList (= List<ArtistData>)
class ArtistsWithTagTransformer<ResultType> implements StreamTransformer<List<TypedResult>, ResultType> {
  final MoodtagDB _moodtagDB;
  final Set<Tag>? filterTags;

  StreamController<ResultType> _controller = StreamController();
  Map<Artist, ArtistData> artistToEnhancedArtistMap = {};

  ArtistsWithTagTransformer(this._moodtagDB, {this.filterTags});

  @override
  Stream<ResultType> bind(Stream<List<TypedResult>> stream) {
    stream.listen((List<TypedResult> typedResults) {
      artistToEnhancedArtistMap = {};
      typedResults.forEach((queryResult) {
        final artist = queryResult.readTable(_moodtagDB.artists);
        final tag = queryResult.readTableOrNull(_moodtagDB.tags);
        final artistWithTags = artistToEnhancedArtistMap.putIfAbsent(artist, () => ArtistData(artist, Set<Tag>()));
        if (tag != null) {
          artistWithTags.tags.add(tag);
        }
      });

      if (filterTags != null && filterTags!.isNotEmpty) {
        artistToEnhancedArtistMap
            .removeWhere((artist, artistWithTags) => artistWithTags.tags.intersection(filterTags!).isEmpty);
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
