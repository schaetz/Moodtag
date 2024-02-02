import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/form/widgets/entity_selector.dart';
import 'package:moodtag/shared/dialogs/variants/select_entity/single_select_entity_dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'dialog_form_field.dart';

class EntitySelectionDialogFormField<E extends NamedEntity> extends DialogFormField<E> {
  final List<E> entities;
  final EntityDialogSelectionStyle selectionStyle;
  final Icon Function(E)? iconSelector;

  const EntitySelectionDialogFormField(super.identifier,
      {required super.initialValue, required this.entities, required this.selectionStyle, this.iconSelector});

  bool get showBoxOutlineOnSelectedTile =>
      selectionStyle == EntityDialogSelectionStyle.ONE_TAP ||
      selectionStyle == EntityDialogSelectionStyle.BOX_OUTLINE ||
      selectionStyle == EntityDialogSelectionStyle.BOX_OUTLINE_AND_LEADING_ICON;

  @override
  Widget buildWidget(Function(String fieldId, E newValue) formUpdateCallback) {
    return EntitySelector<E>(this, updateFormState: (E newValue) => formUpdateCallback(this.identifier, newValue));
  }
}
