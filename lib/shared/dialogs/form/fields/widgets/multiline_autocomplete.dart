import 'package:flutter/material.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../text_dialog_form_field.dart';

class MultilineAutocomplete extends StatefulWidget {
  final TextDialogFormField _formField;
  final Function(String) updateFormState;

  const MultilineAutocomplete(this._formField, {super.key, required this.updateFormState});

  @override
  State<StatefulWidget> createState() =>
      _MultilineAutocompleteState(this._formField, updateFormState: this.updateFormState);
}

class _MultilineAutocompleteState extends State<MultilineAutocomplete> {
  final TextDialogFormField _formField;
  final Map<String, Set<String>> _optionsByInputPatterns;
  final Function(String) updateFormState;

  TextEditingController? _textEditingController;
  String _lastInput;

  _MultilineAutocompleteState(this._formField, {required this.updateFormState})
      : _lastInput = _formField.initialValue,
        _optionsByInputPatterns =
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
          final currentLine = textEditingValue.text.split('\n').last;
          final currentLineNormalized = currentLine.toLowerCase().trim();
          if (currentLineNormalized.isEmpty) {
            return const Iterable<String>.empty();
          }

          final matchingPatternsWithOptions = _optionsByInputPatterns.entries
              .where((entry) => entry.key.startsWith(currentLineNormalized) && currentLine != entry.key);
          return matchingPatternsWithOptions.map((entry) => entry.value).expand((setOfOptions) => setOfOptions).toSet();
        },
        onSelected: (selectedValue) => _formField.multiline
            ? _addValueAtLastLineOfTextInput(_formField, selectedValue)
            : updateFormState(selectedValue));
  }

  Widget _buildTextFieldWidget(
      TextDialogFormField formField, TextEditingController? textEditingController, FocusNode? focusNode) {
    _textEditingController = textEditingController;
    return TextField(
        controller: textEditingController,
        focusNode: focusNode,
        minLines: 1,
        maxLines: formField.getMaxLines(multilineDefault: 10),
        maxLength: 255,
        onChanged: (value) {
          _lastInput = value;
          updateFormState(value);
        });
  }

  void _addValueAtLastLineOfTextInput(TextDialogFormField formField, String selectedValue) {
    if (_textEditingController == null) return;

    final currentTextValue = _lastInput;
    final newLines = currentTextValue.split('\n')
      ..removeLast()
      ..add(selectedValue);
    final newInput = newLines.join('\n') + '\n';
    _textEditingController!.value =
        TextEditingValue(text: newInput, selection: TextSelection.collapsed(offset: newInput.length));
    updateFormState(newInput);
  }
}
