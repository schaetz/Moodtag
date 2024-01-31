import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/alert_dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

class SelectEntityDialogConfig<E extends NamedEntity> extends AlertDialogConfig<E> {
  final List<E> availableEntities;
  final E? initialSelection;
  final EntityDialogSelectionStyle selectionStyle;
  final Icon Function(E)? iconSelector;

  const SelectEntityDialogConfig(
      {String? super.title,
      super.subtitle,
      required super.actions,
      super.onTerminate,
      // Dialog-specific properties
      required this.availableEntities,
      this.initialSelection,
      required this.selectionStyle,
      this.iconSelector});

  bool get showBoxOutlineOnSelectedTile =>
      selectionStyle == EntityDialogSelectionStyle.ONE_TAP ||
      selectionStyle == EntityDialogSelectionStyle.BOX_OUTLINE ||
      selectionStyle == EntityDialogSelectionStyle.BOX_OUTLINE_AND_LEADING_ICON;
}

enum EntityDialogSelectionStyle { ONE_TAP, RADIO_BUTTONS, BOX_OUTLINE, BOX_OUTLINE_AND_LEADING_ICON }
