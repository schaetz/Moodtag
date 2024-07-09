import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_artist.dart';

typedef BaseArtistsTagsMap = Map<BaseArtist, List<BaseTag>>;

class GenericImportProcessorMixin {
  Future<Map<I, BaseArtist>> getBaseArtistsForImportArtists<I extends ImportedArtist>(
      Set<I> importArtists, Repository repository) async {
    final artistsByName = await repository.getBaseArtistsByNameMap();
    return Map.fromEntries(importArtists
        .map((importArtist) => artistsByName.containsKey(importArtist.name)
            ? MapEntry(importArtist, artistsByName[importArtist.name]!)
            : null)
        .nonNulls);
  }
}
