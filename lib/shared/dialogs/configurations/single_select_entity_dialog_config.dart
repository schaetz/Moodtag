import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/core/alert_dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../form/fields/entity_selection_dialog_form_field.dart';

/**
 *  Configuration for a dialog with a single widget
 *  to select a NamedEntity from a list
 *
 *  E: Type of the selected entity = result type of the dialog
 */
class SingleSelectEntityDialogConfig<E extends NamedEntity> extends AlertDialogConfig<E> {
  static const singleSelectionInputId = 'selection';

  final List<E> availableEntities;
  final E initialSelection;
  final EntityDialogSelectionStyle selectionStyle;
  final Icon Function(E)? iconSelector;

  SingleSelectEntityDialogConfig(
      {String? super.title,
      super.subtitle,
      required super.actions,
      super.onTerminate,
      // Dialog-specific properties
      required this.availableEntities,
      required this.initialSelection,
      required this.selectionStyle,
      this.iconSelector})
      : super(formFields: [
          EntitySelectionDialogFormField<E, E>(singleSelectionInputId,
              entities: availableEntities,
              initialValue: initialSelection,
              selectionStyle: selectionStyle,
              iconSelector: iconSelector,
              oneTapResultConverter: (entity) => entity)
        ]);

  bool get showBoxOutlineOnSelectedTile =>
      selectionStyle == EntityDialogSelectionStyle.ONE_TAP ||
      selectionStyle == EntityDialogSelectionStyle.BOX_OUTLINE ||
      selectionStyle == EntityDialogSelectionStyle.BOX_OUTLINE_AND_LEADING_ICON;
}

enum EntityDialogSelectionStyle { ONE_TAP, RADIO_BUTTONS, BOX_OUTLINE, BOX_OUTLINE_AND_LEADING_ICON }
