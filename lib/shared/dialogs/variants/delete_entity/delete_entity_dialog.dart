import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/abstract_dialog.dart';
import 'package:moodtag/shared/dialogs/components/options/dialog_option.dart';
import 'package:moodtag/shared/dialogs/components/options/simple_text_dialog_option.dart';

import 'delete_entity_dialog_config.dart';

typedef R = bool;

/**
 *  Dialog to confirm the deletion of an entity
 *
 *  R: Result type = bool
 *  E: Type of the entity
 */
class DeleteEntityDialog<E> extends AbstractDialog<R, DeleteEntityDialogConfig<R, E>> {
  static DeleteEntityDialog construct<E>(BuildContext context,
      {String? title,
      String? subtitle,
      Function(R?)? onTerminate,
      // Dialog-specific properties
      required E? entityToDelete}) {
    return DeleteEntityDialog<E>(
        context,
        DeleteEntityDialogConfig<R, E>(
            title: title,
            subtitle: subtitle,
            options: _getYesNoOptions(),
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
