import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/configurations/result_types/delete_with_replacement_result.dart';
import 'package:moodtag/shared/dialogs/core/alert_dialog_config.dart';
import 'package:moodtag/shared/dialogs/form/fields/entity_selection/entity_selection_dialog_form_field.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'single_select_entity_dialog_config.dart';

class DeleteWithReplacementConfig<E extends NamedEntity> extends AlertDialogConfig<DeleteWithReplacementResult<E>> {
  static const singleSelectionInputId = 'selection';

  final List<E> availableEntities;
  final E? initialSelection;
  final EntityDialogSelectionStyle selectionStyle;
  final Icon Function(E)? iconSelector;
  final bool replacementActive;

  DeleteWithReplacementConfig(
      {super.title,
      super.subtitle,
      required super.actions,
      super.onTerminate,
      // Dialog-specific properties
      required this.availableEntities,
      required this.initialSelection,
      required this.selectionStyle,
      this.iconSelector,
      required this.replacementActive})
      : super(
            formFields: replacementActive && initialSelection != null
                ? [
                    EntitySelectionDialogFormField<DeleteWithReplacementResult<E>, E>(singleSelectionInputId,
                        entities: availableEntities,
                        initialValue: initialSelection,
                        selectionStyle: selectionStyle,
                        iconSelector: iconSelector,
                        oneTapResultConverter: (E entity) =>
                            DeleteWithReplacementResult(confirmDeletion: true, replacement: entity))
                  ]
                : []);
}
