import 'package:drift/drift.dart';

import 'moodtag_db.dart';

extension DataClassExtension on DataClass {
  String getName() {
    if (this is Artist) {
      return (this as Artist).name;
    } else if (this is Tag) {
      return (this as Tag).name;
    }
    return 'UNKNOWN';
  }
}
