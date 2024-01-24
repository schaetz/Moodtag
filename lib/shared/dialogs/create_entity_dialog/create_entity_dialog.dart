import 'package:flutter/material.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/dialogs/dialog_config.dart';
import 'package:moodtag/shared/dialogs/simple_text_input_dialog_base.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';
import 'package:moodtag/shared/utils/i10n.dart';

import '../abstract_dialog.dart';
import 'create_entity_dialog_config.dart';

/**
 *  Dialog for creating generic entities (like artists or tags)
 *
 *  E: Type of the entity to create = result type of the dialog
 *  O: Type of other entities that may be affected (E=artist => O=tag and vice versa)
 *  S: Type of the suggested entities
 */
class CreateEntityDialog<E, O, S extends NamedEntity> extends AbstractDialog<E, CreateEntityDialogConfig<E, O, S>> {
  static CreateEntityDialog construct<E, O, S extends NamedEntity>(BuildContext context,
      {String? title,
      DialogOptionType dialogOptionType = DialogOptionType.simpleDialogOptionWithText,
      required OptionObjectToHandler<E> options,
      Function(E?)? onTerminate,
      // Dialog-specific properties
      O? preselectedOtherEntity,
      required Function(String) onSendInput,
      List<S>? suggestedEntities = null}) {
    return CreateEntityDialog<E, O, S>(
        context,
        CreateEntityDialogConfig<E, O, S>(
            title: title,
            options: options,
            onTerminate: onTerminate,
            // Dialog-specific properties
            preselectedOtherEntity: preselectedOtherEntity,
            onSendInput: onSendInput,
            suggestedEntities: suggestedEntities));
  }

  CreateEntityDialog(super.context, super.config);

  CreateEntityDialog.withFuture(
      BuildContext context, Future<CreateEntityDialogConfig<E, O, S>> Function(BuildContext) getRequiredData)
      : super.withFuture(context, getRequiredData: getRequiredData);

  @override
  Widget buildDialog(BuildContext context) {
    return SimpleTextInputDialogBase(
      message: 'Enter the name of the ${I10n.getEntityDenotation(type: E, plural: false)}:',
      confirmationButtonLabel: 'OK',
      onSendInput: (String newInput) {
        config.onSendInput(newInput);
        this.closeDialog(context);
      },
      suggestedEntities: config.suggestedEntities,
    );
  }
}

typedef AddArtistDialog = CreateEntityDialog<Artist, Tag, NamedEntity>;
typedef AddTagDialog = CreateEntityDialog<Tag, Artist, NamedEntity>;
