import 'package:moodtag/shared/dialogs/dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

/**
 *  Configuration for dialogs that allow the user to create entities
 *
 *  E: Type of the created entity
 *  O: Type of other entities that may be affected (E=artist => O=tag and vice versa)
 *  S: Type of the suggested entities
 */
class CreateEntityDialogConfig<E, O, S extends NamedEntity> extends DialogConfig<E> {
  final O? preselectedOtherEntity;
  final Function(String) onSendInput;
  final List<S>? suggestedEntities;

  CreateEntityDialogConfig({
    super.title,
    required super.options,
    super.onTerminate,
    // Dialog-specific properties
    this.preselectedOtherEntity,
    required this.onSendInput,
    this.suggestedEntities,
  }) : super(dialogOptionType: DialogOptionType.simpleDialogOptionWithText);
}
