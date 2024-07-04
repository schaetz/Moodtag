import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_config.dart';

abstract class AbstractImportState {
  Enum get step;
  AbstractImportConfig? get importConfig;
}
