import 'package:moodtag/shared/dialogs/configurations/alert_dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../core/dialog_action.dart';
import '../form/fields/text_input/text_dialog_form_field.dart';

/**
 *  Configuration for dialogs with a single text field;
 *  used for entity creation
 *
 *  S: Type of the suggested entities
 */
class SingleTextInputDialogConfig<S extends NamedEntity> extends AlertDialogConfig<String> {
  static const singleTextInputId = 'input';

  static SingleTextInputDialogConfig<S> create<S extends NamedEntity>(
    String? title,
    String? subtitle,
    Function(String?)? onTerminate,
    // Dialog-specific properties
    {
    bool multiline = false,
    int? maxLines,
    Set<S>? suggestedEntities,
  }) {
    final actions = _getTextInputConfirmationActions(singleTextInputId);
    final textFormField = TextDialogFormField(singleTextInputId, '',
        multiline: multiline, maxLines: maxLines, suggestions: suggestedEntities);

    return SingleTextInputDialogConfig<S>._construct(title, subtitle, [textFormField], actions, onTerminate);
  }

  SingleTextInputDialogConfig._construct(
      String? super.title,
      String? super.subtitle,
      List<TextDialogFormField> super.formFields,
      List<DialogAction<String>> super.actions,
      Function(String?)? super.onTerminate);

  static List<DialogAction<String>> _getTextInputConfirmationActions(String mainInputId) => [
        DialogAction<String>('Confirm',
            getDialogResult: (context, formState) => formState?.get<String>(mainInputId) ?? null,
            validate: (context, formState) => formState?.get<String>(mainInputId)?.isNotEmpty == true),
        DialogAction<String>('Discard', getDialogResult: (context, formState) => null),
      ];
}
