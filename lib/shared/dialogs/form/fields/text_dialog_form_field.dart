import 'package:flutter/material.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'dialog_form_field.dart';
import 'widgets/multiline_autocomplete.dart';

class TextDialogFormField extends DialogFormField {
  final bool multiline;
  final int? maxLines;
  final Set<NamedEntity>? suggestions;

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

  @override
  Widget buildWidget(Function(String fieldId, String newValue) formUpdateCallback) {
    if (this.suggestions != null) {
      return MultilineAutocomplete(this, updateFormState: (newValue) => formUpdateCallback(this.identifier, newValue));
    }
    return _buildTextFieldWidget(this, formUpdateCallback);
  }

  Widget _buildTextFieldWidget(
          TextDialogFormField formField, Function(String fieldId, String newValue) formUpdateCallback) =>
      TextField(
          minLines: 1,
          maxLines: formField.getMaxLines(multilineDefault: 10),
          maxLength: 255,
          onChanged: (value) => formUpdateCallback(formField.identifier, value));
}
