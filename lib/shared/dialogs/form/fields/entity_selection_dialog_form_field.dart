import 'package:flutter/material.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../../configurations/single_select_entity_dialog_config.dart';
import 'dialog_form_field.dart';
import 'widgets/entity_selector.dart';

/**
 *  Configuration class for the EntitySelector widget
 *
 *  R: Result type of the dialog
 *  E: Type of the selected entity
 */
class EntitySelectionDialogFormField<R, E extends NamedEntity> extends DialogFormField<E> {
  final List<E> entities;
  final EntityDialogSelectionStyle selectionStyle;
  final Icon Function(E)? iconSelector;
  final R Function(E) oneTapResultConverter;

  const EntitySelectionDialogFormField(super.identifier,
      {required super.initialValue,
      required this.entities,
      required this.selectionStyle,
      this.iconSelector,
      required this.oneTapResultConverter});

  bool get showBoxOutlineOnSelectedTile =>
      selectionStyle == EntityDialogSelectionStyle.ONE_TAP ||
      selectionStyle == EntityDialogSelectionStyle.BOX_OUTLINE ||
      selectionStyle == EntityDialogSelectionStyle.BOX_OUTLINE_AND_LEADING_ICON;

  @override
  Widget buildWidget(
      {required final FormUpdateCallback<E> formUpdateCallback, required final CloseDialogHandle closeDialog}) {
    return EntitySelector<R, E>(this,
        updateFormState: (E newValue) => formUpdateCallback(this.identifier, newValue),
        closeDialog: closeDialog,
        oneTapResultConverter: this.oneTapResultConverter);
  }
}
