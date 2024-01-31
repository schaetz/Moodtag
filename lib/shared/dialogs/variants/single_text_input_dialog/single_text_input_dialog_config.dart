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

  final List<S>? suggestedEntities;

  const SingleTextInputDialogConfig.singleLine({
    super.title,
    super.subtitle,
    required super.actions,
    super.onTerminate,
    // Dialog-specific properties
    this.suggestedEntities,
  }) : super(formFields: const [TextDialogFormField(singleTextInputId, initialValue: '', multiline: false)]);

  SingleTextInputDialogConfig.multiline({
    super.title,
    super.subtitle,
    required super.actions,
    super.onTerminate,
    // Dialog-specific properties
    final int? maxLines,
    this.suggestedEntities,
  }) : super(formFields: [
          TextDialogFormField(
            singleTextInputId,
            initialValue: '',
            multiline: true,
            maxLines: maxLines,
          )
        ]);
}
