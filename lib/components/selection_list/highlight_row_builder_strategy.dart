import 'package:flutter/material.dart';
import 'package:moodtag/components/selection_list/row_builder_strategy.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

class HighlightRowBuilderStrategy<E extends NamedEntity> extends RowBuilderStrategy<E> {
  static const normalEntityColor = Colors.black;
  static const highlightEntityColor = Colors.indigo;
  static const listEntryStyle = TextStyle(fontSize: 20.0);
  static const subtitleColor = Colors.black54;
  static const subtitleIconSize = 18.0;
  static const subtitleStyle = TextStyle(fontSize: 14.0, color: subtitleColor);

  final bool Function(E) doHighlightEntity;
  final IconData? Function(E)? getMainIcon;
  final IconData? Function(E)? getSubtitleIcon;
  final String? Function(E)? getSubtitleText;

  HighlightRowBuilderStrategy(
      {required this.doHighlightEntity, this.getMainIcon, this.getSubtitleIcon, this.getSubtitleText});

  @override
  Widget buildRow(int index,
      {required E entity,
      required bool isChecked,
      required Function(bool?, int) onListTileChanged,
      required bool isDisabled}) {
    return CheckboxListTile(
        title: RichText(
            text: TextSpan(style: listEntryStyle.copyWith(color: _getEntityColor(entity)), children: [
          TextSpan(
            text: entity.name,
          ),
          if (doHighlightEntity(entity))
            WidgetSpan(child: Padding(padding: const EdgeInsets.only(left: 2.0), child: _getMainIcon(entity)))
        ])),
        subtitle: _getSubtitle(entity),
        activeColor: _getEntityColor(entity),
        enabled: !isDisabled,
        selected: isChecked,
        value: isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (newValue) => onListTileChanged(newValue, index));
  }

  Widget? _getMainIcon(E entity) {
    if (getMainIcon == null || getMainIcon!(entity) == null) {
      return null;
    }
    return Icon(getMainIcon!(entity));
  }

  Widget? _getSubtitle(E entity) {
    if (getSubtitleText == null || getSubtitleText!(entity) == null) {
      return null;
    }

    final subtitleText = getSubtitleText!(entity)!;
    if (getSubtitleIcon != null) {
      return RichText(
          text: TextSpan(children: [
        WidgetSpan(
            child: Icon(
              getSubtitleIcon!(entity) ?? null,
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
