/**
 *  Superclass for all types of form fields that may occur
 *  in alert dialogs, such as text inputs
 */
abstract class DialogFormField<T> {
  final String identifier;
  final T initialValue;

  const DialogFormField(this.identifier, {required this.initialValue});
}
