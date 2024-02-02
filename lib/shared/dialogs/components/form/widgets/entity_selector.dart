import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/form/fields/entity_selection_dialog_form_field.dart';
import 'package:moodtag/shared/dialogs/variants/select_entity/single_select_entity_dialog_config.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

class EntitySelector<E extends NamedEntity> extends StatefulWidget {
  final EntitySelectionDialogFormField<E> _formField;
  final Function(E) updateFormState;

  const EntitySelector(this._formField, {super.key, required this.updateFormState});

  @override
  State<StatefulWidget> createState() => _EntitySelectorState<E>(_formField, updateFormState: this.updateFormState);
}

class _EntitySelectorState<E extends NamedEntity> extends State<EntitySelector<E>> {
  final EntitySelectionDialogFormField<E> _formField;
  final Function(E) updateFormState;

  E? _selection;

  _EntitySelectorState(this._formField, {required this.updateFormState});

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
      // TODO Confirm the selection on a single tap
    }
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
