import 'package:moodtag/shared/dialogs/core/alert_dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../form/fields/text_input/text_dialog_form_field.dart';

/**
 *  Configuration for dialogs with a single text field;
 *  used for entity creation
 *
 *  S: Type of the suggested entities
 */
class SingleTextInputDialogConfig<S extends NamedEntity> extends AlertDialogConfig<String> {
  static const singleTextInputId = 'input';

  SingleTextInputDialogConfig({
    super.title,
    super.subtitle,
    required super.actions,
    super.onTerminate,
    // Dialog-specific properties
    bool multiline = false,
    int? maxLines,
    Set<S>? suggestedEntities,
  }) : super(formFields: [
          TextDialogFormField(singleTextInputId,
              initialValue: '', multiline: multiline, maxLines: maxLines, suggestions: suggestedEntities)
        ]);
}
