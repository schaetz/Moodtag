import 'package:flutter/material.dart';
import 'package:moodtag/structs/named_entity.dart';

class RowBuilderStrategy<E extends NamedEntity> {
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  Widget buildRow(int index,
      {required E entity, required bool isChecked, required Function(bool?, int) onListTileChanged}) {
    return CheckboxListTile(
        title: Text(
          entity.name,
          style: listEntryStyle,
        ),
        value: isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (newValue) => onListTileChanged(newValue, index));
  }
}
