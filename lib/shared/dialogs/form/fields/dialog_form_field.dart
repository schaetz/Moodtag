import 'package:flutter/material.dart';

/**
 *  Superclass for all types of form fields that may occur
 *  in alert dialogs, such as text inputs
 */
abstract class DialogFormField<T> {
  final String identifier;
  final T initialValue;

  const DialogFormField(this.identifier, {required this.initialValue});

  Widget buildWidget(
      {required final FormUpdateCallback<T> formUpdateCallback, required final CloseDialogHandle closeDialog});

  @override
  String toString() => '{$identifier, ${initialValue.toString()}}';
}

typedef FormUpdateCallback<T> = Function(String fieldId, T newValue);
typedef CloseDialogHandle<R> = Function(BuildContext context, {R? result});
