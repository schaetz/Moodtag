import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/form/text_dialog_form_field.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

class MultilineAutocomplete extends StatelessWidget {
  final TextDialogFormField _formField;
  final Map<String, Set<String>> _optionsByInputPatterns;
  final Function(String) updateFormState;

  MultilineAutocomplete(this._formField, {super.key, required this.updateFormState})
      : _optionsByInputPatterns =
            _formField.suggestions != null ? _getOptionsFromNamedEntities(_formField.suggestions!) : {};

  static Map<String, Set<String>> _getOptionsFromNamedEntities(Set<NamedEntity> suggestions) {
    final _optionsMap = Map<String, Set<String>>();
    suggestions.forEach((entity) {
      final name = entity.name;
      final normalizedName = entity.name.toLowerCase();
      _optionsMap.update(normalizedName, (value) => value..add(name), ifAbsent: () => {name});
      if (entity is OrderingName) {
        final normalizedOrderingName = (entity as OrderingName).orderingName.toLowerCase();
        _optionsMap.update(normalizedOrderingName, (value) => value..add(name), ifAbsent: () => {name});
      }
    });
    return _optionsMap;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode,
                VoidCallback onFieldSubmitted) =>
            _buildTextFieldWidget(_formField, textEditingController, focusNode),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.trim() == '') {
            return const Iterable<String>.empty();
          }

          final currentLine = textEditingValue.text.split('\n').last.toLowerCase().trim();
          final matchingPatternsWithOptions =
              _optionsByInputPatterns.entries.where((entry) => entry.key.startsWith(currentLine));
          return matchingPatternsWithOptions.map((entry) => entry.value).expand((setOfOptions) => setOfOptions).toSet();
        },
        onSelected: (selectedValue) => _formField.multiline
            ? _addValueAtLastLineOfTextInput(_formField, selectedValue)
            : updateFormState(selectedValue));
  }

  Widget _buildTextFieldWidget(
          TextDialogFormField formField, TextEditingController? textEditingController, FocusNode? focusNode) =>
      TextField(
          controller: textEditingController,
          focusNode: focusNode,
          minLines: 1,
          maxLines: formField.getMaxLines(multilineDefault: 10),
          maxLength: 255,
          onChanged: (value) => updateFormState(value));

  void _addValueAtLastLineOfTextInput(TextDialogFormField formField, String selectedValue) {
    // Selected option will currently just overwrite all existing lines;
    // How do I access the TextEditingController here?
    final currentTextValue = '';
    final newLines = currentTextValue.split('\n')
      ..removeLast()
      ..add(selectedValue);
    print(newLines);
    final newInput = newLines.join('\n');
    updateFormState(newInput);
  }
}
