import 'package:flutter/material.dart';
import 'package:moodtag/structs/named_entity.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';

import '../components/mt_app_bar.dart';

class SelectionListScreen<T extends NamedEntity> extends StatefulWidget {

  final String mainButtonLabel;
  final Function(BuildContext, List<String>, List<bool>) onMainButtonPressed;

  SelectionListScreen({
    this.mainButtonLabel,
    this.onMainButtonPressed,
  });

  @override
  State<StatefulWidget> createState() => _SelectionListScreenState<T>();

}


class _SelectionListScreenState<T extends NamedEntity> extends State<SelectionListScreen> {

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  List<bool> _isBoxSelected;
  int _selectedBoxesCount;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as UniqueNamedEntitySet<T>;
    print(args);
    final List<String> listValues = List.from(args.values.map((entity) => entity.name));
    listValues.sort();

    if (_isBoxSelected == null) {
      _setBoxSelections(listValues.length, true);
    }

    return Scaffold(
      appBar: MtAppBar(context),
      body: ListView.separated(
        separatorBuilder: (context, _) => Divider(),
        padding: EdgeInsets.all(16.0),
        itemCount: listValues.length,
        itemBuilder: (context, i) {
          return _buildRow(context, listValues[i], i);
        },
      ),
      floatingActionButton: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 32),
              child: _buildFloatingSelectButton(context, listValues.length),
            ),
            FloatingActionButton.extended(
              onPressed: () => widget.onMainButtonPressed(context, listValues, _isBoxSelected),
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