import 'package:flutter/material.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

class RowBuilderStrategy<E extends NamedEntity> {
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  Widget buildRow(int index,
      {required E entity,
      required bool isChecked,
      required Function(bool?, int) onListTileChanged,
      required bool isDisabled}) {
    return CheckboxListTile(
        title: Text(
          entity.name,
          style: listEntryStyle,
        ),
        value: isChecked,
        enabled: !isDisabled,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (newValue) => onListTileChanged(newValue, index));
  }
}
