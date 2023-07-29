import 'package:flutter/material.dart';
import 'package:moodtag/components/selection_list/row_builder_strategy.dart';
import 'package:moodtag/structs/named_entity.dart';

class HighlightRowBuilderStrategy<E extends NamedEntity> extends RowBuilderStrategy<E> {
  static const normalEntityColor = Colors.black;
  static const highlightEntityColor = Colors.indigo;
  static const listEntryStyle = TextStyle(fontSize: 20.0);
  static const subtitleColor = Colors.black54;
  static const subtitleIconSize = 18.0;
  static const subtitleStyle = TextStyle(fontSize: 14.0, color: subtitleColor);

  final bool Function(E) doHighlightEntity;
  final bool Function(E) doDisableEntity;
  final String? Function(E)? getSubtitleText;
  final IconData? subtitleIcon;

  HighlightRowBuilderStrategy(
      {required this.doHighlightEntity, required this.doDisableEntity, this.getSubtitleText, this.subtitleIcon});

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
        subtitle: _getSubtitle(entity),
        activeColor: _getEntityColor(entity),
        enabled: !doDisableEntity(entity),
        selected: isChecked,
        value: isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (newValue) => onListTileChanged(newValue, index));
  }

  Widget? _getSubtitle(entity) {
    if (getSubtitleText == null || getSubtitleText!(entity) == null) {
      return null;
    }

    final subtitleText = getSubtitleText!(entity)!;
    if (subtitleIcon != null) {
      return RichText(
          text: TextSpan(children: [
        WidgetSpan(
            child: Icon(
              subtitleIcon,
              size: subtitleIconSize,
              color: subtitleColor,
            ),
            style: subtitleStyle),
        WidgetSpan(
          child: SizedBox(width: 4),
        ),
        TextSpan(text: subtitleText, style: subtitleStyle)
      ]));
    }

    return Text(subtitleText);
  }

  Color _getEntityColor(E entity) => doHighlightEntity(entity) ? highlightEntityColor : normalEntityColor;
}
