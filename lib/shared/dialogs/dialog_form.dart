import 'package:flutter/material.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'dialog_form_field.dart';

class DialogFormFactory {
  const DialogFormFactory();

  DialogForm createForm(List<DialogFormField> formFields, Function(DialogFormState) formStateCallback, {Key? key}) =>
      DialogForm(formFields, formStateCallback, key: key);
}

class DialogForm extends StatefulWidget {
  final List<DialogFormField> formFields;
  final Function(DialogFormState) formStateCallback;

  const DialogForm(this.formFields, this.formStateCallback, {super.key});

  @override
  State<StatefulWidget> createState() => DialogFormState.init(formFields, formStateCallback);
}

class DialogFormState extends State<DialogForm> {
  final Function(DialogFormState) formStateCallback;

  Map<String, Object?> _values; // Map from field id to current state

  DialogFormState.init(List<DialogFormField> formFields, this.formStateCallback)
      : _values = Map.fromEntries(formFields.map((field) => MapEntry(field.identifier, field.initialValue)));

  T? get<T>(String fieldId) => _values[fieldId] is T ? _values[fieldId] as T : null;

  @override
  Widget build(BuildContext context) => Row(
          children: widget.formFields.map((field) {
        switch (field.type) {
          case DialogFormFieldType.textInput:
            return Expanded(child: _buildTextInput(context, field));
        }
      }).toList());

  Widget _buildTextInput(BuildContext context, DialogFormField formField) {
    if (formField.suggestions == null) {
      return _buildTextFieldWidget(formField, null, null);
    }

    return Autocomplete<String>(
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode,
              VoidCallback onFieldSubmitted) =>
          _buildTextFieldWidget(formField, textEditingController, focusNode),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }

        final trimmedTextEditingValue = textEditingValue.text.toLowerCase().trim();
        // TODO There should not be references to DataClassWithEntityName and orderingName here (tight coupling!)
        return formField.suggestions!.where((NamedEntity option) {
          final optionName = option.name.toLowerCase();
          final optionOrderingName = option is DataClassWithEntityName ? option.orderingName : optionName;
          return optionName.startsWith(trimmedTextEditingValue) ||
              optionOrderingName.startsWith(trimmedTextEditingValue);
        }).map((matchingEntity) => matchingEntity.name);
      },
      onSelected: (selectedValue) => _updateValue(formField.identifier, selectedValue),
    );
  }

  Widget _buildTextFieldWidget(
          DialogFormField formField, TextEditingController? textEditingController, FocusNode? focusNode) =>
      TextField(
          controller: textEditingController,
          focusNode: focusNode,
          maxLines: null,
          maxLength: 255,
          onChanged: (value) => _updateValue(formField.identifier, value));

  void _updateValue(String fieldId, Object? newValue) {
    final newValues = Map<String, Object?>.from(_values)..putIfAbsent(fieldId, () => newValue);
    setState(() {
      _values = newValues;
    });
    formStateCallback(this);
  }
}
