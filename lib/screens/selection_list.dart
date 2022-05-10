import 'package:flutter/material.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

import '../components/mt_app_bar.dart';

class SelectionList<T extends NamedEntity> extends StatefulWidget {

  final UniqueNamedEntitySet<T> namedEntitySet;
  final String mainButtonLabel;
  final Function(BuildContext, List<T>, List<bool>) onMainButtonPressed;

  SelectionList({
    this.namedEntitySet,
    this.mainButtonLabel,
    this.onMainButtonPressed,
  });

  @override
  State<StatefulWidget> createState() => _SelectionListState<T>();

}


class _SelectionListState<T extends NamedEntity> extends State<SelectionList> {

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  List<bool> _isBoxSelected;
  int _selectedBoxesCount;

  @override
  Widget build(BuildContext context) {
    final List<T> sortedEntities = widget.namedEntitySet.toSortedList();

    if (_isBoxSelected == null) {
      _setBoxSelections(sortedEntities.length, true);
    }

    return Scaffold(
      appBar: MtAppBar(context),
      body: ListView.separated(
        separatorBuilder: (context, _) => Divider(),
        padding: EdgeInsets.all(16.0),
        itemCount: sortedEntities.length,
        itemBuilder: (context, i) {
          return _buildRow(context, sortedEntities[i].name, i);
        },
      ),
      floatingActionButton: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 32),
              child: _buildFloatingSelectButton(context, sortedEntities.length),
            ),
            FloatingActionButton.extended(
              onPressed: () => widget.onMainButtonPressed(context, sortedEntities, _isBoxSelected),
              label: Text(widget.mainButtonLabel),
              icon: const Icon(Icons.add_circle_outline),
              backgroundColor: Theme.of(context).colorScheme.secondary,
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

  Widget _buildRow(BuildContext context, String entityName, int index) {
    return CheckboxListTile(
        title: Text(
          entityName,
          style: listEntryStyle,
        ),
        value: _isBoxSelected[index],
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool newValue) {
          setState(() {
            _isBoxSelected[index] = newValue;
            if (newValue == true) {
              _selectedBoxesCount++;
            } else {
              _selectedBoxesCount--;
            }
          });
        }
    );
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