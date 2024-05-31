import 'dart:async';

import 'package:drift/drift.dart';
import 'package:moodtag/model/repository/helpers/dto.dart';

import '../moodtag_db.dart';

typedef OptionalArtistWithTagsDTO = ArtistWithTagsDTO?;

/**
 *  Transformer to transform raw SQL results with pairs of artists and joined tags (containing redundancy)
 *  to ArtistWithTagsDTO objects; The results can be filtered by tags.
 *  It is important to filter by tag IDs rather than the TagDataClass objects themselves, as other properties of Tag
 *  such as category may have changed since setting up the subscription and may lead to false inequality.
 */
// Result type is either ArtistWithTagsDTO or List<ArtistWithTagsDTO>
class ArtistsWithTagTransformer<ResultType> implements StreamTransformer<List<TypedResult>, ResultType> {
  final MoodtagDB _moodtagDB;
  final Set<int>? filterTagIds;

  StreamController<ResultType> _controller = StreamController();
  Map<ArtistDataClass, ArtistWithTagsDTO> artistToDtoMap = {};

  ArtistsWithTagTransformer(this._moodtagDB, {this.filterTagIds});

  @override
  Stream<ResultType> bind(Stream<List<TypedResult>> stream) {
    stream.listen((List<TypedResult> typedResults) {
      artistToDtoMap = {};
      typedResults.forEach((queryResult) {
        final artistDataClass = queryResult.readTable(_moodtagDB.artists);
        final tagDataClass = queryResult.readTableOrNull(_moodtagDB.tags);
        // Create new ArtistData object or get the existing one for artist
        final artistWithTags =
            artistToDtoMap.putIfAbsent(artistDataClass, () => ArtistWithTagsDTO(artist: artistDataClass, tags: []));
        if (tagDataClass != null) {
          artistWithTags.tags.add(tagDataClass);
        }
      });

      if (filterTagIds != null && filterTagIds!.isNotEmpty) {
        artistToDtoMap.removeWhere((artist, artistWithTags) =>
            artistWithTags.tags.map((tag) => tag.id).toSet().intersection(filterTagIds!).isEmpty);
      }

      if (ResultType == ArtistWithTagsDTO || ResultType == OptionalArtistWithTagsDTO) {
        if (artistToDtoMap.values.isNotEmpty) {
          _controller.add(artistToDtoMap.values.first as ResultType);
        }
      } else if (ResultType == List<ArtistWithTagsDTO>) {
        _controller.add(artistToDtoMap.values.toList() as ResultType);
      }
    });
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
