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
class ArtistsDtoTransformer<ResultType> implements StreamTransformer<List<TypedResult>, ResultType> {
  final MoodtagDB _moodtagDB;
  final Set<int>? filterTagIds;

  StreamController<ResultType> _controller = StreamController();

  ArtistsDtoTransformer(this._moodtagDB, {this.filterTagIds});

  @override
  Stream<ResultType> bind(Stream<List<TypedResult>> stream) {
    stream.listen((List<TypedResult> typedResults) {
      final artistDataToDtoMap = createNewMapFromQueryResults(typedResults);

      // Apply filters, if given
      if (filterTagIds != null && filterTagIds!.isNotEmpty) {
        artistDataToDtoMap.removeWhere(
            (artistData, dto) => dto.tags.map((tag) => tag.id).toSet().intersection(filterTagIds!).isEmpty);
      }

      // Add either the single artist DTO or a list of DTOs to the StreamController
      if (ResultType == ArtistWithTagsDTO || ResultType == OptionalArtistWithTagsDTO) {
        if (artistDataToDtoMap.values.isNotEmpty) {
          _controller.add(artistDataToDtoMap.values.first as ResultType);
        }
      } else if (ResultType == List<ArtistWithTagsDTO>) {
        _controller.add(artistDataToDtoMap.values.toList() as ResultType);
      }
    });
    return _controller.stream;
  }

  Map<ArtistDataClass, ArtistWithTagsDTO> createNewMapFromQueryResults(List<TypedResult> typedResults) {
    final Map<ArtistDataClass, ArtistWithTagsDTO> newArtistDataToDtoMap = {};
    typedResults.forEach((queryResult) {
      final artistDataClass = queryResult.readTable(_moodtagDB.artists);
      final tagDataClass = queryResult.readTableOrNull(_moodtagDB.tags);

      // Create new ArtistWithTagsDTO object or get the existing one for artist
      final artistWithTagsDto = newArtistDataToDtoMap.putIfAbsent(
          artistDataClass, () => ArtistWithTagsDTO(artist: artistDataClass, tags: []));
      if (tagDataClass != null) {
        artistWithTagsDto.tags.add(tagDataClass);
      }
    });
    return newArtistDataToDtoMap;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
