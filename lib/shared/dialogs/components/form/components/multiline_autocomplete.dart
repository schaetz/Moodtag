import 'package:flutter/material.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/shared/dialogs/components/form/text_dialog_form_field.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

class MultilineAutocomplete extends StatelessWidget {
  final TextDialogFormField _formField;
  final Function(String) updateFormState;

  const MultilineAutocomplete(this._formField, {super.key, required this.updateFormState});

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
          // TODO There should not be references to DataClassWithEntityName and orderingName here (tight coupling!)
          return _formField.suggestions!.where((NamedEntity option) {
            final optionName = option.name.toLowerCase();
            final optionOrderingName = option is DataClassWithEntityName ? option.orderingName : optionName;
            return optionName.startsWith(currentLine) || optionOrderingName.startsWith(currentLine);
          }).map((matchingEntity) => matchingEntity.name);
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
