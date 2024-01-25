import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog_config.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog_mixin.dart';
import 'package:moodtag/shared/dialogs/dialog_option.dart';
import 'package:moodtag/shared/dialogs/simple_text_dialog_option.dart';

import '../abstract_dialog.dart';

typedef R = bool;

/**
 *  Dialog to confirm the deletion of an entity
 *
 *  R: Result type = bool
 *  E: Type of the entity
 */
class DeleteEntityDialog<E> extends AbstractDialog<R, DeleteEntityDialogConfig<R, E>>
    with DeleteEntityDialogMixin<E, R> {
  static DeleteEntityDialog construct<E>(BuildContext context,
      {String? title,
      required Function(R) handleResult,
      Function(R?)? onTerminate,
      // Dialog-specific properties
      required E? entityToDelete}) {
    return DeleteEntityDialog<E>(
        context,
        DeleteEntityDialogConfig<R, E>(
            title: title,
            options: _getYesNoOptions(),
            handleResult: handleResult,
            onTerminate: onTerminate,
            // Dialog-specific properties
            entityToDelete: entityToDelete));
  }

  static List<DialogOption<bool>> _getYesNoOptions() {
    return [
      SimpleTextDialogOption<bool>('Yes', (context, formState) => true),
      SimpleTextDialogOption<bool>('No', (context, formState) => false),
    ];
  }

  DeleteEntityDialog(super.context, super.config);

  DeleteEntityDialog.withFuture(
      BuildContext context, Future<DeleteEntityDialogConfig<R, E>> Function(BuildContext) getRequiredData)
      : super.withFuture(context, getRequiredData: getRequiredData);
}
