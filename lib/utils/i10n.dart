import 'package:moodtag/model/database/moodtag_db.dart';

class I10n {
  static const UNKNOWN_ENTITY_DENOTATION_SINGULAR = 'entity';
  static const UNKNOWN_ENTITY_DENOTATION_PLURAL = 'entities';

  static const ARTIST_DENOTATION_SINGULAR = 'artist';
  static const ARTIST_DENOTATION_PLURAL = 'artists';

  static const TAG_DENOTATION_SINGULAR = 'tag';
  static const TAG_DENOTATION_PLURAL = 'tags';

  static String getEntityDenotation({Type type, bool plural = false}) {
    if (type == Artist) {
      return plural ? I10n.ARTIST_DENOTATION_PLURAL : I10n.ARTIST_DENOTATION_SINGULAR;
    } else if (type == Tag) {
      return plural ? I10n.TAG_DENOTATION_PLURAL : I10n.TAG_DENOTATION_SINGULAR;
    }

    return plural ? I10n.UNKNOWN_ENTITY_DENOTATION_PLURAL : I10n.UNKNOWN_ENTITY_DENOTATION_SINGULAR;
  }
}
