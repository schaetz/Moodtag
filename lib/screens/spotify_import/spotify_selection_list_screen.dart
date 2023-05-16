import 'package:flutter/material.dart';
import 'package:moodtag/screens/selection_list_screen.dart';
import 'package:moodtag/structs/import_entity.dart';
import 'package:moodtag/structs/imported_genre.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

// Subclass of the generic SelectionListScreen and used by ImportSelectionListScreen;
// The state overwrites the styling of the individual rows to display additional information (if entities already exist)
class SpotifySelectionListScreen<E extends ImportEntity> extends SelectionListScreen<E> {
  SpotifySelectionListScreen(
      {required UniqueNamedEntitySet<E> namedEntitySet,
      required String mainButtonLabel,
      required Function(BuildContext p1, List<E> p2, List<bool> p3, int p4) onMainButtonPressed})
      : super(
            namedEntitySet: namedEntitySet, mainButtonLabel: mainButtonLabel, onMainButtonPressed: onMainButtonPressed);

  @override
  State<StatefulWidget> createState() => _SpotifySelectionListScreenState<E>();
}

class _SpotifySelectionListScreenState<E extends ImportEntity> extends SelectionListScreenState<E> {
  static const normalEntityColor = Colors.black;
  static const existingEntityColor = Colors.indigo;
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  Widget buildRow(BuildContext context,
      {required E entity, required bool isChecked, required Function(bool?) onChanged}) {
    return CheckboxListTile(
        title: RichText(
            text: TextSpan(style: listEntryStyle.copyWith(color: _getEntityColor(entity)), children: [
          TextSpan(
            text: entity.name,
          ),
          if (entity.alreadyExists)
            WidgetSpan(
                child: Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: (E == _typeOf<ImportedGenre>()) ? Icon(Icons.check) : Icon(Icons.update)))
        ])),
        activeColor: _getEntityColor(entity),
        enabled: !_isDisabled(entity),
        selected: isChecked,
        value: isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged);
  }

  Color _getEntityColor(ImportEntity entity) => entity.alreadyExists ? existingEntityColor : normalEntityColor;

  bool _isDisabled(ImportEntity entity) => entity.alreadyExists && E == _typeOf<ImportedGenre>();

  Type _typeOf<T>() => T;
}
