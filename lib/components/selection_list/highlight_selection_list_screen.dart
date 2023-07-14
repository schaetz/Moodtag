import 'package:flutter/material.dart';
import 'package:moodtag/components/selection_list/selection_list_config.dart';
import 'package:moodtag/structs/named_entity.dart';

import 'selection_list_screen.dart';

// Extension of the generic SelectionListScreen that highlights
// or disables certain checkbox list tiles
class HighlightSelectionListScreen<E extends NamedEntity> extends StatelessWidget {
  static const normalEntityColor = Colors.black;
  static const highlightEntityColor = Colors.indigo;
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  late final SelectionListConfig<E> config;
  final Function(E) doHighlightEntity;
  final Function(E) doDisableEntity;

  HighlightSelectionListScreen(
      {super.key,
      required SelectionListConfig<E> config,
      required this.doHighlightEntity,
      required this.doDisableEntity}) {
    this.config = config.copyWith(rowBuilder: _buildRow);
  }

  @override
  Widget build(BuildContext context) {
    return SelectionListScreen(config);
  }

  Widget _buildRow(E entity, bool isChecked, Function(bool?) _onListTileChanged) {
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
        onChanged: _onListTileChanged);
  }

  Color _getEntityColor(E entity) => doHighlightEntity(entity) ? highlightEntityColor : normalEntityColor;
}
