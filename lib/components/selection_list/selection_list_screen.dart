import 'package:flutter/material.dart';
import 'package:moodtag/structs/named_entity.dart';

import 'row_builder_strategy.dart';
import 'selection_list_config.dart';

// A generic screen that displays a list of named entities with checkboxes
// and has a FloatingActionButton for carrying out an action on the entities.
// The default rowBuilder function can be overridden to customize the layout
// of the CheckboxListTiles.
class SelectionListScreen<E extends NamedEntity> extends StatefulWidget {
  final SelectionListConfig<E> config;
  late final RowBuilderStrategy<E> rowBuilderStrategy;

  SelectionListScreen({required this.config, required this.rowBuilderStrategy});

  SelectionListScreen.defaultStyle(this.config) {
    this.rowBuilderStrategy = RowBuilderStrategy<E>();
  }

  @override
  State<StatefulWidget> createState() => SelectionListScreenState<E>();
}

class SelectionListScreenState<E extends NamedEntity> extends State<SelectionListScreen<E>> {
  late final List<E> _sortedEntities;
  Map<E, bool> _isBoxSelected = {};
  int _selectedBoxesCount = 0;
  Set<E> _enabledEntities = {};
  Set<E> _disabledEntities = {};
  int _selectedDisabledBoxesCount = 0;

  @override
  void initState() {
    super.initState();
    _sortedEntities = widget.config.namedEntitySet.toSortedList();
    _initializeBoxSelections(true);
    _collectEnabledAndDisabledEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.config.appBar,
      body: widget.config.scaffoldBodyWrapperFactory.create(
          bodyWidget: ListView.separated(
        separatorBuilder: (context, _) => Divider(),
        padding: EdgeInsets.all(16.0),
        itemCount: _sortedEntities.length,
        itemBuilder: (context, i) => widget.rowBuilderStrategy.buildRow(i,
            entity: _sortedEntities[i],
            isChecked: _isBoxSelected[_sortedEntities[i]] ?? false,
            onListTileChanged: _onListTileChanged,
            isDisabled: _disabledEntities.contains(_sortedEntities[i])),
      )),
      floatingActionButton: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 32),
              child: _buildFloatingSelectButton(context),
            ),
            FloatingActionButton.extended(
              onPressed: () => _isSelectionValid()
                  ? widget.config.onMainButtonPressed(context, _sortedEntities, _isBoxSelected, _selectedBoxesCount)
                  : null,
              label: Text(widget.config.mainButtonLabel),
              icon: const Icon(Icons.add_circle_outline),
              backgroundColor: _isSelectionValid()
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey, // TODO Define color in theme
              heroTag: 'main_button',
            ),
          ],
        ),
      ),
    );
  }

  void _initializeBoxSelections(bool value) {
    setState(() {
      _isBoxSelected = Map.fromEntries(_sortedEntities.map((entity) => MapEntry(entity, value)));
      _selectedBoxesCount = value == true ? _sortedEntities.length : 0;
    });
  }

  void _setAllEnabledBoxSelections(bool newValue) {
    setState(() {
      _isBoxSelected.updateAll((entity, oldValue) => _enabledEntities.contains(entity) ? newValue : oldValue);
      _selectedBoxesCount =
          newValue == true ? _enabledEntities.length + _selectedDisabledBoxesCount : _selectedDisabledBoxesCount;
    });
  }

  void _collectEnabledAndDisabledEntities() {
    final Set<E> enabledEntities = {};
    final Set<E> disabledEntities = {};
    var selectedDisabledBoxesCount = 0;

    if (widget.config.doDisableEntity == null) {
      enabledEntities.addAll(_sortedEntities);
    } else {
      _sortedEntities.forEach((entity) {
        if (!widget.config.doDisableEntity!(entity)) {
          enabledEntities.add(entity);
        } else {
          disabledEntities.add(entity);
          if (_isBoxSelected[entity] == true) {
            selectedDisabledBoxesCount++;
          }
        }
      });
    }

    setState(() {
      _enabledEntities = enabledEntities;
      _disabledEntities = disabledEntities;
      _selectedDisabledBoxesCount = selectedDisabledBoxesCount;
    });
  }

  bool _isSelectionValid() => _selectedBoxesCount > 0;

  void _onListTileChanged(bool? newValue, int index) {
    setState(() {
      if (newValue != null) {
        _isBoxSelected[_sortedEntities[index]] = newValue;
        if (newValue == true) {
          _selectedBoxesCount++;
        } else {
          _selectedBoxesCount--;
        }
      }
    });
  }

  Widget _buildFloatingSelectButton(BuildContext context) {
    final enabledEntitiesCount = _sortedEntities.length - _disabledEntities.length;
    final selectedEnabledBoxesCount = _selectedBoxesCount - _selectedDisabledBoxesCount;
    if (selectedEnabledBoxesCount == enabledEntitiesCount) {
      return FloatingActionButton.extended(
        onPressed: () => _setAllEnabledBoxSelections(false),
        label: const Text('Select none'),
        icon: const Icon(Icons.remove_circle_outline),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        heroTag: 'select_button',
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () => _setAllEnabledBoxSelections(true),
        label: const Text('Select all'),
        icon: const Icon(Icons.select_all_outlined),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        heroTag: 'select_button',
      );
    }
  }
}
