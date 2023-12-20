import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/structs/imported_entities/imported_tag.dart';
import 'package:moodtag/structs/imported_entities/spotify_artist.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';

class SpotifyImportProcessor {
  final Map<SpotifyArtist, Artist> createdArtistsByEntity = Map();
  final Map<String, Tag> createdTagsByGenreName = Map();

  Future<DbRequestSuccessCounter> conductImport(
      List<SpotifyArtist> artistsToImport, List<ImportedTag> genresToImport, Repository repository) async {
    await repository.createImportedArtistsInBatch(artistsToImport);
    await repository.createImportedTagsInBatch(genresToImport);

    final failedAssignments = await _assignTagsToCreatedArtists(artistsToImport, genresToImport, repository);
    return DbRequestSuccessCounter.instantiate(
        artistsToImport.length, artistsToImport.length - failedAssignments, failedAssignments);
  }

  Future<int> _assignTagsToCreatedArtists(
      List<SpotifyArtist> artistsToImport, List<ImportedTag> genresToImport, Repository repository) async {
    Map<String, Artist> createdArtistsByName = await _getCreatedArtistsByName(repository, artistsToImport);
    Map<String, Tag> createdTagsByName = await _getCreatedTagsByName(repository, genresToImport);

    var failedAssignments = 0;
    Map<Artist, List<Tag>> tagsForArtistsMap = Map();
    for (SpotifyArtist importArtist in artistsToImport) {
      Artist? correspondingArtist = createdArtistsByName[importArtist.name] ?? null;
      if (correspondingArtist == null) {
        failedAssignments++;
        continue;
      }
      final assignedTagsIterable =
          importArtist.tags.map((assignedTagName) => createdTagsByName[assignedTagName] ?? null).nonNulls;
      if (assignedTagsIterable.nonNulls.length < assignedTagsIterable.length) {
        failedAssignments++;
      }
      tagsForArtistsMap.putIfAbsent(correspondingArtist, () => assignedTagsIterable.nonNulls.toList());
    }

    await repository.assignTagsToArtistsInBatch(tagsForArtistsMap);
    return failedAssignments;
  }

  Future<Map<String, Artist>> _getCreatedArtistsByName(
      Repository repository, List<SpotifyArtist> artistsToImport) async {
    final createdArtists = await repository.getLatestArtistsOnce(artistsToImport.length);
    final createdArtistsByName = Map.fromEntries(
        createdArtists.map((createdArtist) => MapEntry<String, Artist>(createdArtist.name, createdArtist)));
    return createdArtistsByName;
  }

  Future<Map<String, Tag>> _getCreatedTagsByName(
    Repository repository,
    List<ImportedTag> genresToImport,
  ) async {
    final createdTags = await repository.getLatestTagsOnce(genresToImport.length);
    final createdTagsByName =
        Map.fromEntries(createdTags.map((createdTag) => MapEntry<String, Tag>(createdTag.name, createdTag)));
    return createdTagsByName;
  }
}
