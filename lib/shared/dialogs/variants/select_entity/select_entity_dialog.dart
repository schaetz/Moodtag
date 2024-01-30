import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/abstract_dialog.dart';
import 'package:moodtag/shared/dialogs/components/options/dialog_option.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'select_entity_dialog_config.dart';
import 'select_entity_dialog_form.dart';

/**
 *  Dialog that allows the user to select a single entity from a list
 *
 *  E: Type of the selectable entities = result type of the dialog
 */
class SelectEntityDialog<E extends NamedEntity> extends AbstractDialog<E, SelectEntityDialogConfig<E>> {
  static SelectEntityDialog<E> construct<E extends NamedEntity>(BuildContext context,
      {String? title,
      String? subtitle,
      required List<DialogOption<E>> options,
      Function(E?)? onTerminate,
      // Dialog-specific properties
      required List<E> availableEntities,
      E? initialSelection,
      required EntityDialogSelectionStyle selectionStyle,
      Icon Function(E)? iconSelector}) {
    return SelectEntityDialog<E>(
        context,
        SelectEntityDialogConfig(
            title: title,
            subtitle: subtitle,
            options: options,
            onTerminate: onTerminate,
            // Dialog-specific properties
            availableEntities: availableEntities,
            initialSelection: initialSelection,
            selectionStyle: selectionStyle,
            iconSelector: iconSelector));
  }

  SelectEntityDialog(super.context, super.config);

  SelectEntityDialog.withFuture(
      BuildContext context, Future<SelectEntityDialogConfig<E>> Function(BuildContext) getRequiredData)
      : super.withFuture(context, getRequiredData: getRequiredData);

  @override
  Widget buildDialog(BuildContext context) {
    return SelectEntityDialogForm<E>(config);
  }
}
