import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/form/fields/dialog_form_field.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import '../../../configurations/single_select_entity_dialog_config.dart';
import '../entity_selection_dialog_form_field.dart';

class EntitySelector<E extends NamedEntity> extends StatefulWidget {
  final EntitySelectionDialogFormField<E> _formField;
  final Function(E) updateFormState;
  final CloseDialogHandle closeDialog;

  const EntitySelector(this._formField, {super.key, required this.updateFormState, required this.closeDialog});

  @override
  State<StatefulWidget> createState() =>
      _EntitySelectorState<E>(_formField, updateFormState: this.updateFormState, closeDialog: this.closeDialog);
}

class _EntitySelectorState<E extends NamedEntity> extends State<EntitySelector<E>> {
  final EntitySelectionDialogFormField<E> _formField;
  final Function(E) updateFormState;
  final CloseDialogHandle closeDialog;

  E? _selection;

  _EntitySelectorState(this._formField, {required this.updateFormState, required this.closeDialog});

  @override
  void initState() {
    super.initState();
    setState(() {
      _selection = _formField.initialValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: _formField.entities
            .map((entity) => ListTile(
                shape: _formField.showBoxOutlineOnSelectedTile
                    ? Border.all(
                        width: 4.0,
                        color: _selection == entity ? Theme.of(context).colorScheme.outline : Colors.transparent)
                    : null,
                leading: _getLeadingWidgetOnListTile(entity),
                title: Text(entity.name),
                onTap: () => _handleListTileTap(entity)))
            .toList());
  }

  void _handleListTileTap(E entity) {
    setState(() {
      this._selection = entity;
    });
    if (_formField.selectionStyle == EntityDialogSelectionStyle.ONE_TAP) {
      closeDialog(context, result: entity);
    }
    updateFormState(entity);
  }

  Widget? _getLeadingWidgetOnListTile(E entity) {
    switch (_formField.selectionStyle) {
      case EntityDialogSelectionStyle.ONE_TAP:
        if (_formField.iconSelector == null) {
          return null;
        }
        return _formField.iconSelector!(entity);
      case EntityDialogSelectionStyle.RADIO_BUTTONS:
        return Radio<E>(
          value: entity,
          groupValue: _selection,
          onChanged: (E? value) => setState(() {
            this._selection = value;
          }),
        );
      case EntityDialogSelectionStyle.BOX_OUTLINE:
        return null;
      case EntityDialogSelectionStyle.BOX_OUTLINE_AND_LEADING_ICON:
        if (_formField.iconSelector == null) {
          return null;
        }
        return _formField.iconSelector!(entity);
    }
  }
}
