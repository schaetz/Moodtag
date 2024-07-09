import 'package:moodtag/features/import/abstract_import_flow/connectors/generic_import_processor_mixin.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/models/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/shared/models/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/shared/utils/db_request_success_counter.dart';

class SpotifyImportProcessor with GenericImportProcessorMixin {
  final Map<SpotifyArtist, BaseArtist> createdArtistsByEntity = Map();
  final Map<String, BaseTag> createdTagsByGenreName = Map();

  Future<DbRequestSuccessCounter> conductImport(
      List<SpotifyArtist> artistsToImport, List<ImportedTag> tagsToImport, Repository repository) async {
    await repository.createImportedArtistsInBatch(artistsToImport);
    await repository.createImportedTagsInBatch(tagsToImport);

    Set<SpotifyArtist> failedAssignments = {};

    final failedTagAssignments = await _assignTagsToCreatedArtists(artistsToImport, tagsToImport, repository);
    failedAssignments.addAll(failedTagAssignments);

    // TODO Create a better data structure for DbRequestSuccessCounter
    return DbRequestSuccessCounter.instantiate(
        artistsToImport.length, artistsToImport.length - failedAssignments.length, failedAssignments.length);
  }

  Future<Set<SpotifyArtist>> _assignTagsToCreatedArtists(
      List<SpotifyArtist> artistsToImport, List<ImportedTag> tagsToImport, Repository repository) async {
    final (tagsForArtistsMap, failedAssignments) =
        await _getMapFromCreatedArtistsToCreatedTags(artistsToImport, tagsToImport, repository);
    await repository.assignTagsToArtistsInBatch(tagsForArtistsMap);
    return failedAssignments;
  }

  Future<(BaseArtistsTagsMap, Set<SpotifyArtist>)> _getMapFromCreatedArtistsToCreatedTags(
      List<SpotifyArtist> artistsToImport, List<ImportedTag> tagsToImport, Repository repository) async {
    Map<String, BaseArtist> createdArtistsByName =
        await repository.getBaseArtistsByNameMap(repository, latestX: artistsToImport.length);
    Map<String, BaseTag> createdTagsByName =
        await repository.getBaseTagsByNameMap(repository, latestX: tagsToImport.length);

    Set<SpotifyArtist> failedAssignments = {};
    BaseArtistsTagsMap tagsForArtistsMap = Map();

    for (SpotifyArtist importArtist in artistsToImport) {
      BaseArtist? correspondingArtist = createdArtistsByName[importArtist.name] ?? null;
      if (correspondingArtist == null) {
        failedAssignments.add(importArtist);
        continue;
      }
      final tagsToAssignIterable =
          importArtist.tags.map((assignedTagName) => createdTagsByName[assignedTagName] ?? null).nonNulls;
      if (tagsToAssignIterable.nonNulls.length < tagsToAssignIterable.length) {
        failedAssignments.add(importArtist);
      }
      tagsForArtistsMap.putIfAbsent(correspondingArtist, () => tagsToAssignIterable.nonNulls.toList());
    }

    return (tagsForArtistsMap, failedAssignments);
  }
}
