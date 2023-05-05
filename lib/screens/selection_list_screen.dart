import 'package:flutter/material.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

import '../components/mt_app_bar.dart';

class SelectionListScreen<T extends NamedEntity> extends StatefulWidget {
  final UniqueNamedEntitySet<T> namedEntitySet;
  final String mainButtonLabel;
  final Function(BuildContext, List<T>, List<bool>, int) onMainButtonPressed;

  SelectionListScreen({
    required this.namedEntitySet,
    required this.mainButtonLabel,
    required this.onMainButtonPressed,
  });

  @override
  State<StatefulWidget> createState() => _SelectionListScreenState<T>();
}

class _SelectionListScreenState<T extends NamedEntity> extends State<SelectionListScreen> {
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  late final List<T> _sortedEntities;
  List<bool> _isBoxSelected = [];
  int _selectedBoxesCount = 0;

  @override
  void initState() {
    super.initState();
    _sortedEntities = widget.namedEntitySet.toSortedList() as List<T>;
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
          return _buildRow(context, _sortedEntities[i].name, i);
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

  Widget _buildRow(BuildContext context, String entityName, int index) {
    return CheckboxListTile(
        title: Text(
          entityName,
          style: listEntryStyle,
        ),
        value: _isBoxSelected[index],
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool? newValue) {
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
        });
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
