import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/repository.dart';

typedef BaseArtistsTagsMap = Map<BaseArtist, List<BaseTag>>;

mixin GenericImportProcessorMixin {
  Future<void> assignInitialTags(
      List<BaseArtist> importedArtists, List<BaseTag> initialTags, Repository repository) async {
    Map<BaseArtist, List<BaseTag>> tagsForArtistsMap = Map();
    for (BaseArtist artist in importedArtists) {
      tagsForArtistsMap.putIfAbsent(artist, () => initialTags);
    }

    await repository.assignTagsToArtistsInBatch(tagsForArtistsMap);
  }
}
