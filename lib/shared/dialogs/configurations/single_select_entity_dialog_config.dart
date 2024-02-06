import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/configurations/alert_dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../core/dialog_action.dart';
import '../form/fields/dialog_form_field.dart';
import '../form/fields/entity_selection/entity_selection_dialog_form_field.dart';

/**
 *  Configuration for a dialog with a single widget
 *  to select a NamedEntity from a list
 *
 *  E: Type of the selected entity = result type of the dialog
 */
class SingleSelectEntityDialogConfig<E extends NamedEntity> extends AlertDialogConfig<E> {
  final EntitySelectionDialogFormField<E, E> selectionFormField;

  static SingleSelectEntityDialogConfig<E> create<E extends NamedEntity>(
      String? title,
      String? subtitle,
      Function(E?)? onTerminate,
      // Dialog-specific properties
      List<E> entities,
      E initialSelection,
      EntityDialogSelectionStyle selectionStyle,
      Icon Function(E)? iconSelector) {
    final List<DialogAction<E>> actions = selectionStyle == EntityDialogSelectionStyle.ONE_TAP
        ? const []
        : _getSelectEntityConfirmationActions<E>(EntitySelectionDialogFormField.singleSelectionInputId);
    final selectionFormField = EntitySelectionDialogFormField.getSingleSelectionField<E, E>(
        entities, initialSelection, selectionStyle, iconSelector, (entity) => entity);

    return SingleSelectEntityDialogConfig<E>._construct(title, subtitle, [selectionFormField], actions, onTerminate,
        entities, initialSelection, selectionStyle, iconSelector, selectionFormField);
  }

  SingleSelectEntityDialogConfig._construct(
      String? super.title,
      String? super.subtitle,
      List<DialogFormField> super.formFields,
      List<DialogAction<E>> super.actions,
      Function(E?)? super.onTerminate,
      // Dialog-specific properties
      List<E> entities,
      E initialSelection,
      EntityDialogSelectionStyle selectionStyle,
      Icon Function(E)? iconSelector,
      this.selectionFormField);

  static List<DialogAction<E>> _getSelectEntityConfirmationActions<E extends NamedEntity>(String mainInputId) => [
        DialogAction<E>('Confirm',
            getDialogResult: (context, formState) => formState?.get<E>(mainInputId) ?? null,
            validate: (context, formState) => true),
        DialogAction<E>('Discard', getDialogResult: (context, formState) => null),
      ];
}
