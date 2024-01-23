import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/select_entity/select_entity_dialog_form.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../abstract_dialog.dart';
import 'select_entity_dialog_config.dart';

class SelectEntityDialog<E extends NamedEntity> extends AbstractDialog<E> {
  final SelectEntityDialogConfig<E> config;

  SelectEntityDialog(BuildContext context,
      {required String title,
      required List<E> availableEntities,
      E? initialSelection,
      required Function(E) onSendInput,
      required EntityDialogSelectionStyle selectionStyle,
      Icon Function(E)? iconSelector})
      : config = SelectEntityDialogConfig(
            title: title,
            availableEntities: availableEntities,
            initialSelection: initialSelection,
            onSendInput: onSendInput,
            selectionStyle: selectionStyle,
            iconSelector: iconSelector),
        super(context);
  SelectEntityDialog.withConfig(BuildContext context, this.config) : super(context);

  @override
  Widget buildDialog(BuildContext context) {
    return SelectEntityDialogForm<E>(config);
  }
}
