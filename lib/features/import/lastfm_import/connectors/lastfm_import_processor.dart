import 'package:moodtag/features/import/abstract_import_flow/connectors/generic_import_processor_mixin.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/models/structs/imported_entities/lastfm_artist.dart';

class LastFmImportProcessor with GenericImportProcessorMixin {
  final Map<LastFmArtist, Artist> createdArtistsByEntity = Map();

  Future<void> conductImport(List<LastFmArtist> artistsToImport, BaseTag? initialTag, Repository repository) async {
    final latestArtistId = await repository.getLatestArtistId(repository);
    await repository.createImportedArtistsInBatch(artistsToImport);

    if (initialTag != null) {
      // TODO: In the future artists can also be updated, so we cannot simply get all artists that have been added
      final artistIdThreshold = latestArtistId == null ? 0 : latestArtistId;
      final createdArtists = await repository.getBaseArtistsWithIdAboveOnce(artistIdThreshold);
      await assignInitialTags(createdArtists, [initialTag], repository);
    }
  }
}
