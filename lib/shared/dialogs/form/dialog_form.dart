import 'package:flutter/material.dart';

import 'fields/dialog_form_field.dart';

class DialogFormFactory {
  const DialogFormFactory();

  DialogForm createForm<R>(List<DialogFormField> formFields, Function(DialogFormState) formStateCallback,
          CloseDialogHandle<R> closeDialog,
          {Key? key}) =>
      DialogForm<R>(formFields, formStateCallback, closeDialog, key: key);
}

/**
 *  Widget that includes all configured form fields
 *  of an AlertDialog
 *
 *  R: result type of the dialog
 */
class DialogForm<R> extends StatefulWidget {
  final List<DialogFormField> formFields;
  final Function(DialogFormState) formStateCallback;
  final Function(BuildContext context, {R? result}) closeDialog;

  const DialogForm(this.formFields, this.formStateCallback, this.closeDialog, {super.key});

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
      children: widget.formFields
          .map((formField) => Expanded(
              child: formField.buildWidget(
                  formUpdateCallback: (fieldId, newValue) => _updateValue(fieldId, newValue),
                  closeDialog: widget.closeDialog)))
          .toList());

  void _updateValue(String fieldId, Object? newValue) {
    final newValues = Map<String, Object?>.from(_fieldValues)..update(fieldId, (_) => newValue);
    setState(() {
      _fieldValues = newValues;
    });
    _formStateCallback(this);
  }
}
