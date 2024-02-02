import 'package:flutter/material.dart';

/**
 *  Superclass for all types of form fields that may occur
 *  in alert dialogs, such as text inputs
 */
abstract class DialogFormField<T> {
  final String identifier;
  final T initialValue;
  Widget buildWidget(Function(String fieldId, T newValue) formUpdateCallback);

  const DialogFormField(this.identifier, {required this.initialValue});
}
