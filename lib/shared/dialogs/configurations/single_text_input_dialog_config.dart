import 'package:moodtag/shared/dialogs/core/alert_dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../form/fields/text_dialog_form_field.dart';

/**
 *  Configuration for dialogs with a single text field;
 *  used for entity creation
 *
 *  S: Type of the suggested entities
 */
class SingleTextInputDialogConfig<S extends NamedEntity> extends AlertDialogConfig<String> {
  static const singleTextInputId = 'input';

  SingleTextInputDialogConfig.singleLine({
    super.title,
    super.subtitle,
    required super.actions,
    super.onTerminate,
    // Dialog-specific properties
    Set<S>? suggestedEntities,
  }) : super(formFields: [
          TextDialogFormField(singleTextInputId, initialValue: '', multiline: false, suggestions: suggestedEntities)
        ]);

  SingleTextInputDialogConfig.multiline({
    super.title,
    super.subtitle,
    required super.actions,
    super.onTerminate,
    // Dialog-specific properties
    int? maxLines,
    Set<S>? suggestedEntities,
  }) : super(formFields: [
          TextDialogFormField(
            singleTextInputId,
            initialValue: '',
            multiline: true,
            maxLines: maxLines,
            suggestions: suggestedEntities,
          )
        ]);
}
