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
      final createdArtists = await getCreatedArtists(latestArtistId, repository);
      final updatedExistingArtists = await getUpdatedExistingArtists<LastFmArtist>(artistsToImport, repository);
      final artistsToAssign = Set<BaseArtist>()
        ..addAll(createdArtists)
        ..addAll(updatedExistingArtists);

      final BaseArtistsTagsMap mapFromImportedArtistsToInitialTags =
          Map.fromEntries(artistsToAssign.map((artist) => MapEntry(artist, [initialTag])));
      await repository.assignTagsToArtistsInBatch(mapFromImportedArtistsToInitialTags);
    }
  }
}
