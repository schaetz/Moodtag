import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/form/components/multiline_autocomplete.dart';

import 'dialog_form_field.dart';
import 'text_dialog_form_field.dart';

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
  final Function(DialogFormState) _formStateCallback;

  Map<String, Object?> _fieldValues; // Map from field id to current state

  DialogFormState.init(List<DialogFormField> formFields, this._formStateCallback)
      : _fieldValues = Map.fromEntries(formFields.map((field) => MapEntry(field.identifier, field.initialValue)));

  T? get<T>(String fieldId) => _fieldValues[fieldId] is T ? _fieldValues[fieldId] as T : null;

  @override
  Widget build(BuildContext context) => Row(
          children: widget.formFields.map((field) {
        switch (field.runtimeType) {
          case TextDialogFormField:
            return Expanded(child: _buildTextInput(context, field as TextDialogFormField));
          default:
            return Container();
        }
      }).toList());

  Widget _buildTextInput(BuildContext context, TextDialogFormField formField) {
    if (formField.suggestions != null) {
      return MultilineAutocomplete(formField, updateFormState: (value) => _updateValue(formField.identifier, value));
    }
    return _buildTextFieldWidget(formField, null, null);
  }

  Widget _buildTextFieldWidget(
          TextDialogFormField formField, TextEditingController? textEditingController, FocusNode? focusNode) =>
      TextField(
          controller: textEditingController,
          focusNode: focusNode,
          minLines: 1,
          maxLines: formField.getMaxLines(multilineDefault: 10),
          maxLength: 255,
          onChanged: (value) => _updateValue(formField.identifier, value));

  void _updateValue(String fieldId, Object? newValue) {
    final newValues = Map<String, Object?>.from(_fieldValues)..update(fieldId, (_) => newValue);
    setState(() {
      _fieldValues = newValues;
    });
    _formStateCallback(this);
  }
}
