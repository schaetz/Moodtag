import 'dart:async';

import 'package:drift/drift.dart';

import 'join_data_classes.dart';
import 'moodtag_db.dart';

class ArtistsWithTagTransformer implements StreamTransformer<List<TypedResult>, List<ArtistWithTags>> {
  final MoodtagDB _moodtagDB;
  final Set<Tag> filterTags;

  StreamController<List<ArtistWithTags>> _controller = StreamController();
  Map<Artist, ArtistWithTags> artistToEnhancedArtistMap = {};

  ArtistsWithTagTransformer(this._moodtagDB, this.filterTags);

  @override
  Stream<List<ArtistWithTags>> bind(Stream<List<TypedResult>> stream) {
    stream.listen((List<TypedResult> typedResults) {
      artistToEnhancedArtistMap = {};
      typedResults.forEach((queryResult) {
        final artist = queryResult.readTable(_moodtagDB.artists);
        final tag = queryResult.readTable(_moodtagDB.tags);
        final artistWithTags = artistToEnhancedArtistMap.putIfAbsent(artist, () => ArtistWithTags(artist, Set<Tag>()));
        artistWithTags.tags.add(tag);
      });

      if (filterTags.isNotEmpty) {
        artistToEnhancedArtistMap
            .removeWhere((artist, artistWithTags) => artistWithTags.tags.intersection(filterTags!).isEmpty);
      }
      _controller.add(artistToEnhancedArtistMap.values.toList());
    });
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
