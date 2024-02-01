import 'package:moodtag/shared/dialogs/components/alert_dialog_config.dart';
import 'package:moodtag/shared/dialogs/components/form/text_dialog_form_field.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

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
    List<S>? suggestedEntities,
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
    List<S>? suggestedEntities,
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
