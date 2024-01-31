import 'package:moodtag/shared/models/structs/named_entity.dart';

class DialogFormField<T> {
  final String identifier;
  final DialogFormFieldType type;
  final T initialValue;
  final List<NamedEntity>? suggestions;

  const DialogFormField(this.identifier, this.type, {required this.initialValue, this.suggestions});
}

enum DialogFormFieldType { textInput }
