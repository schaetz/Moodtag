import 'package:moodtag/shared/dialogs/components/alert_dialog_config.dart';
import 'package:moodtag/shared/dialogs/components/form/dialog_form_field.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

/**
 *  Configuration for dialogs with a single text field;
 *  used for entity creation
 *
 *  S: Type of the suggested entities
 */
class SingleTextInputDialogConfig<S extends NamedEntity> extends AlertDialogConfig<String> {
  static const singleTextInputId = 'input';

  final List<S>? suggestedEntities;

  const SingleTextInputDialogConfig.singleLine({
    super.title,
    super.subtitle,
    required super.actions,
    super.onTerminate,
    // Dialog-specific properties
    this.suggestedEntities,
  }) : super(formFields: const [
          DialogFormField(singleTextInputId, DialogFormFieldType.textInputSingleLine, initialValue: '')
        ]);

  SingleTextInputDialogConfig.multiline({
    super.title,
    super.subtitle,
    required super.actions,
    super.onTerminate,
    // Dialog-specific properties
    final int? maxLines,
    this.suggestedEntities,
  }) : super(formFields: [
          DialogFormField(singleTextInputId, DialogFormFieldType.textInputMultiline,
              maxLines: maxLines, initialValue: '')
        ]);
}
