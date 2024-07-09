import 'package:moodtag/features/import/abstract_import_flow/connectors/generic_import_processor.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/models/structs/imported_entities/lastfm_artist.dart';

class LastFmImportProcessor extends GenericImportProcessorMixin {
  final Map<LastFmArtist, Artist> createdArtistsByEntity = Map();

  Future<void> conductImport(List<LastFmArtist> artistsToImport, BaseTag? initialTag, Repository repository) async {
    final latestArtistId = await repository.getLatestArtistId();
    await repository.createImportedArtistsInBatch(artistsToImport);

    if (initialTag != null) {
      final createdArtists = await _getCreatedArtists(latestArtistId, repository);
      final existingArtists = await _getExistingArtists(artistsToImport, repository);
      final artistsToAssign = Set<BaseArtist>()
        ..addAll(createdArtists)
        ..addAll(existingArtists);

      final BaseArtistsTagsMap mapFromImportedArtistsToInitialTags =
          Map.fromEntries(artistsToAssign.map((artist) => MapEntry(artist, [initialTag])));
      await repository.assignTagsToArtistsInBatch(mapFromImportedArtistsToInitialTags);
    }
  }

  Future<List<BaseArtist>> _getCreatedArtists(int? latestArtistId, Repository repository) async {
    final artistIdThreshold = latestArtistId == null ? 0 : latestArtistId;
    final createdArtists = await repository.getBaseArtistsWithIdAboveOnce(artistIdThreshold);
    return createdArtists;
  }

  Future<List<BaseArtist>> _getExistingArtists(List<LastFmArtist> artistsToImport, Repository repository) async {
    final existingImportArtists = artistsToImport.where((artist) => artist.alreadyExists).toSet();
    final baseArtistsForImportArtists =
        await getBaseArtistsForImportArtists<LastFmArtist>(existingImportArtists, repository);
    return baseArtistsForImportArtists.values.toList();
  }
}
