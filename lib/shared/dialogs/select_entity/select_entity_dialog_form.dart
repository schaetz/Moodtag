import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

import 'select_entity_dialog_config.dart';

class SelectEntityDialogForm<E extends NamedEntity> extends StatefulWidget {
  final SelectEntityDialogConfig<E> config;

  const SelectEntityDialogForm(this.config);

  @override
  State<StatefulWidget> createState() => SelectEntityDialogFormState<E>(config);
}

class SelectEntityDialogFormState<E extends NamedEntity> extends State<SelectEntityDialogForm<E>> {
  final SelectEntityDialogConfig<E> config;

  E? _selection;

  SelectEntityDialogFormState(this.config) : super();

  @override
  void initState() {
    super.initState();
    setState(() {
      _selection = config.initialSelection ?? config.availableEntities.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dialogSize = _getDialogSize();
    return AlertDialog(
      title: Text(config.title),
      content: SizedBox(
          width: dialogSize.width,
          height: dialogSize.height,
          child: Column(
              children: config.availableEntities
                  .map((entity) => ListTile(
                      shape: config.showBoxOutlineOnSelectedTile
                          ? Border.all(
                              width: 4.0,
                              color: _selection == entity ? Theme.of(context).colorScheme.outline : Colors.transparent)
                          : null,
                      leading: _getLeadingWidgetOnListTile(entity),
                      title: Text(entity.name),
                      onTap: () => setState(() {
                            this._selection = entity;
                          })))
                  .toList())),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selection != null ? () => _onOkayPressed() : null,
          child: const Text('OK'),
        ),
      ],
    );
  }

  Size _getDialogSize() => Size(min(MediaQuery.of(context).size.width * 0.75, 400),
      min(MediaQuery.of(context).size.height * 0.75, config.availableEntities.length * 80));

  Widget? _getLeadingWidgetOnListTile(E entity) {
    switch (config.selectionStyle) {
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
        if (config.iconSelector == null) {
          return null;
        }
        return config.iconSelector!(entity);
    }
  }

  void _onOkayPressed() {
    if (_selection != null) {
      config.onSendInput(_selection!);
      Navigator.pop(context, _selection);
    }
  }
}
