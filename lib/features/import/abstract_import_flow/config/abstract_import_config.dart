import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

abstract class AbstractImportConfig extends Equatable {
  TagCategory? get categoryForTags;
  Tag? get initialTagForArtists;

  const AbstractImportConfig();
}
