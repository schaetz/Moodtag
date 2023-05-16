import 'package:flutter/material.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

import '../components/mt_app_bar.dart';

// A generic screen that displays a list of named entities with checkboxes
// and has a FloatingActionButton for carrying out an action on the entities
class SelectionListScreen<E extends NamedEntity> extends StatefulWidget {
  final UniqueNamedEntitySet<E> namedEntitySet;
  final String mainButtonLabel;
  final Function(BuildContext, List<E>, List<bool>, int) onMainButtonPressed;

  SelectionListScreen({
    required this.namedEntitySet,
    required this.mainButtonLabel,
    required this.onMainButtonPressed,
  });

  @override
  State<StatefulWidget> createState() => SelectionListScreenState<E>();
}

class SelectionListScreenState<E extends NamedEntity> extends State<SelectionListScreen> {
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  late final List<E> _sortedEntities;
  List<bool> _isBoxSelected = [];
  int _selectedBoxesCount = 0;

  @override
  void initState() {
    super.initState();
    _sortedEntities = widget.namedEntitySet.toSortedList() as List<E>;
    _setBoxSelections(_sortedEntities.length, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context),
      body: ListView.separated(
        separatorBuilder: (context, _) => Divider(),
        padding: EdgeInsets.all(16.0),
        itemCount: _sortedEntities.length,
        itemBuilder: (context, i) {
          return buildRow(context,
              entity: _sortedEntities[i], isChecked: _isBoxSelected[i], onChanged: _onListTileChanged(i));
        },
      ),
      floatingActionButton: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 32),
              child: _buildFloatingSelectButton(context, _sortedEntities.length),
            ),
            FloatingActionButton.extended(
              onPressed: () => _isSelectionValid()
                  ? widget.onMainButtonPressed(context, _sortedEntities, _isBoxSelected, _selectedBoxesCount)
                  : null,
              label: Text(widget.mainButtonLabel),
              icon: const Icon(Icons.add_circle_outline),
              backgroundColor: _isSelectionValid()
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey, // TODO Define color in theme
              heroTag: 'main_button',
            ),
            //add right Widget here with padding right
          ],
        ),
      ),
    );
  }

  void _setBoxSelections(int entityCount, bool value) {
    setState(() {
      _isBoxSelected = List.filled(entityCount, value);
      _selectedBoxesCount = value == true ? entityCount : 0;
    });
  }

  bool _isSelectionValid() => _selectedBoxesCount > 0;

  Function(bool?) _onListTileChanged(int index) {
    return (bool? newValue) {
      setState(() {
        if (newValue != null) {
          _isBoxSelected[index] = newValue;
          if (newValue == true) {
            _selectedBoxesCount++;
          } else {
            _selectedBoxesCount--;
          }
        }
      });
    };
  }

  Widget buildRow(BuildContext context,
      {required E entity, required bool isChecked, required Function(bool?) onChanged}) {
    return CheckboxListTile(
        title: Text(
          entity.name,
          style: listEntryStyle,
        ),
        value: isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged);
  }

  Widget _buildFloatingSelectButton(BuildContext context, int entityCount) {
    if (_selectedBoxesCount == entityCount) {
      return FloatingActionButton.extended(
        onPressed: () => _setBoxSelections(entityCount, false),
        label: const Text('Select none'),
        icon: const Icon(Icons.remove_circle_outline),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        heroTag: 'select_button',
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () => _setBoxSelections(entityCount, true),
        label: const Text('Select all'),
        icon: const Icon(Icons.select_all_outlined),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        heroTag: 'select_button',
      );
    }
  }
}
