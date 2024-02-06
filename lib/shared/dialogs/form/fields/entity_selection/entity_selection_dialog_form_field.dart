import 'package:flutter/material.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../dialog_form_field.dart';
import 'entity_selector.dart';

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

  static const singleSelectionInputId = 'selection';

  static EntitySelectionDialogFormField<R, E> getSingleSelectionField<R, E extends NamedEntity>(
          List<E> entities,
          E initialSelection,
          EntityDialogSelectionStyle selectionStyle,
          Icon Function(E)? iconSelector,
          R Function(E) oneTapResultConverter) =>
      EntitySelectionDialogFormField<R, E>(
          singleSelectionInputId, initialSelection, entities, selectionStyle, iconSelector, oneTapResultConverter);

  const EntitySelectionDialogFormField(super.identifier, super.initialValue, this.entities, this.selectionStyle,
      this.iconSelector, this.oneTapResultConverter);

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

enum EntityDialogSelectionStyle { ONE_TAP, RADIO_BUTTONS, BOX_OUTLINE, BOX_OUTLINE_AND_LEADING_ICON }
