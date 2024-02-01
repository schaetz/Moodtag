import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'dialog_form_field.dart';

class TextDialogFormField extends DialogFormField {
  final bool multiline;
  final int? maxLines;
  final List<NamedEntity>? suggestions;

  const TextDialogFormField(super.identifier,
      {required super.initialValue, required this.multiline, this.maxLines, this.suggestions});

  int getMaxLines({int multilineDefault = 10}) {
    if (multiline) {
      if (maxLines != null && maxLines! > 0) {
        return maxLines!;
      }
      return multilineDefault;
    }
    return 1;
  }
}
