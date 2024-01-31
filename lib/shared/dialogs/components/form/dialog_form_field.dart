import 'package:moodtag/shared/models/structs/named_entity.dart';

class DialogFormField<T> {
  final String identifier;
  final DialogFormFieldType type;
  final T initialValue;
  final int? maxLines;
  final List<NamedEntity>? suggestions;

  const DialogFormField(this.identifier, this.type, {required this.initialValue, this.maxLines, this.suggestions});
}

enum DialogFormFieldType { textInputSingleLine, textInputMultiline }
