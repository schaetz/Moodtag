import 'package:moodtag/shared/dialogs/components/dialog_config.dart';
import 'package:moodtag/shared/dialogs/components/form/dialog_form_field.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

/**
 *  Configuration for dialogs with a single text field;
 *  used for entity creation
 *
 *  S: Type of the suggested entities
 */
class SingleTextInputDialogConfig<S extends NamedEntity> extends DialogConfig<String?> {
  static const singleTextInputId = 'input';

  final List<S>? suggestedEntities;

  SingleTextInputDialogConfig({
    super.title,
    super.subtitle,
    required super.options,
    super.onTerminate,
    // Dialog-specific properties
    this.suggestedEntities,
  }) : super(formFields: [DialogFormField(singleTextInputId, DialogFormFieldType.textInput, initialValue: '')]);
}
