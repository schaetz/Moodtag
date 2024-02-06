import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/configurations/alert_dialog_config.dart';
import 'package:moodtag/shared/dialogs/configurations/result_types/delete_with_replacement_result.dart';
import 'package:moodtag/shared/dialogs/form/fields/entity_selection/entity_selection_dialog_form_field.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../core/dialog_action.dart';
import '../form/fields/dialog_form_field.dart';

class DeleteWithReplacementConfig<E extends NamedEntity> extends AlertDialogConfig<DeleteReplaceResult<E>> {
  late final EntitySelectionDialogFormField<DeleteReplaceResult<E>, E> selectionFormField;
  // If there is no need for a replacement, the replacement may be deactivated
  // and the dialog will be rendered without the selection field
  final bool replacementActive;

  static DeleteWithReplacementConfig<E> create<E extends NamedEntity>(
      String? title,
      String? subtitle,
      Function(DeleteReplaceResult<E>?)? onTerminate,
      // Dialog-specific properties
      List<E> entities,
      E initialSelection,
      EntityDialogSelectionStyle selectionStyle,
      Icon Function(E)? iconSelector,
      {required bool replacementActive}) {
    final actions = selectionStyle == EntityDialogSelectionStyle.ONE_TAP && replacementActive
        ? [
            DialogAction<DeleteReplaceResult<E>>('Discard',
                getDialogResult: (context, formState) => DeleteReplaceResult<E>(confirmDeletion: false))
          ]
        : _getDeleteWithReplacementActions<E>(EntitySelectionDialogFormField.singleSelectionInputId, replacementActive);
    final selectionFormField = EntitySelectionDialogFormField.getSingleSelectionField<DeleteReplaceResult<E>, E>(
        entities,
        initialSelection,
        selectionStyle,
        iconSelector,
        (E entity) => DeleteReplaceResult(confirmDeletion: true, replacement: entity));

    final List<DialogFormField<E>> formFields = replacementActive ? [selectionFormField] : [];
    return DeleteWithReplacementConfig<E>._construct(
        title, subtitle, formFields, actions, onTerminate, selectionFormField,
        replacementActive: replacementActive);
  }

  DeleteWithReplacementConfig._construct(
      String? super.title,
      String? super.subtitle,
      List<DialogFormField> super.formFields,
      List<DialogAction<DeleteReplaceResult<E>>> super.actions,
      Function(DeleteReplaceResult<E>?)? super.onTerminate,
      this.selectionFormField,
      {required this.replacementActive});

  static List<DialogAction<DeleteReplaceResult<E>>> _getDeleteWithReplacementActions<E extends NamedEntity>(
      String mainInputId, bool replacementActive) {
    if (replacementActive) {
      return [
        DialogAction<DeleteReplaceResult<E>>('Confirm',
            getDialogResult: (context, formState) =>
                DeleteReplaceResult<E>(confirmDeletion: true, replacement: formState?.get<E>(mainInputId)),
            validate: (context, formState) => true),
        DialogAction<DeleteReplaceResult<E>>('Discard',
            getDialogResult: (context, formState) => DeleteReplaceResult<E>(confirmDeletion: false)),
      ];
    }
    return [
      DialogAction<DeleteReplaceResult<E>>('Yes',
          getDialogResult: (context, formState) => DeleteReplaceResult<E>(confirmDeletion: true)),
      DialogAction<DeleteReplaceResult<E>>('No',
          getDialogResult: (context, formState) => DeleteReplaceResult<E>(confirmDeletion: false)),
    ];
  }
}
