import 'package:flutter/material.dart';
import 'package:moodtag/components/selection_list/row_builder_strategy.dart';
import 'package:moodtag/structs/named_entity.dart';

class HighlightRowBuilderStrategy<E extends NamedEntity> extends RowBuilderStrategy<E> {
  static const normalEntityColor = Colors.black;
  static const highlightEntityColor = Colors.indigo;
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  final bool Function(E) doHighlightEntity;
  final bool Function(E) doDisableEntity;

  HighlightRowBuilderStrategy({required this.doHighlightEntity, required this.doDisableEntity});

  @override
  Widget buildRow(int index,
      {required E entity, required bool isChecked, required Function(bool?, int) onListTileChanged}) {
    return CheckboxListTile(
        title: RichText(
            text: TextSpan(style: listEntryStyle.copyWith(color: _getEntityColor(entity)), children: [
          TextSpan(
            text: entity.name,
          ),
          if (doHighlightEntity(entity))
            WidgetSpan(
                child: Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: doDisableEntity(entity) ? Icon(Icons.check) : Icon(Icons.update)))
        ])),
        activeColor: _getEntityColor(entity),
        enabled: !doDisableEntity(entity),
        selected: isChecked,
        value: isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (newValue) => onListTileChanged(newValue, index));
  }

  Color _getEntityColor(E entity) => doHighlightEntity(entity) ? highlightEntityColor : normalEntityColor;
}
