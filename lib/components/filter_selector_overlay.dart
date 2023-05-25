import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/model/database/join_data_classes.dart';

class FilterSelectorOverlay<T extends DataClassWithEntityName> extends StatefulWidget {
  final Map<T, bool> entitiesWithInitialSelection;
  final Function(Set<T>)? onConfirmSelection;
  final Function? onCloseModal;

  const FilterSelectorOverlay(
      {required this.entitiesWithInitialSelection, this.onConfirmSelection = null, this.onCloseModal = null});

  @override
  State<StatefulWidget> createState() => _FilterSelectorOverlayState<T>();
}

class _FilterSelectorOverlayState<T extends DataClassWithEntityName> extends State<FilterSelectorOverlay<T>> {
  static const headlineLabelStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);

  late final Map<T, bool> _selectionsState;
  bool _isClosingAfterButtonClick = false;

  @override
  void initState() {
    super.initState();
    _initializeSelectionsState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.onCloseModal != null && !_isClosingAfterButtonClick) {
      if (widget.onConfirmSelection != null) {
        widget.onConfirmSelection!(_getSelectedSet());
      }
      widget.onCloseModal!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      height: 550,
      child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter artists by tags',
                style: headlineLabelStyle,
              ),
              SizedBox(height: 16),
              Container(
                  height: 350,
                  child: ListView(
                    children: [Wrap(spacing: 8.0, runSpacing: 2.0, children: _buildSelectableChips())],
                  )),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _confirmSelection(context, {}),
                    icon: Icon(Icons.filter_list_off),
                    label: const Text('Clear filters'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _closeOverlay(context),
                    icon: Icon(Icons.undo),
                    label: const Text('Discard'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _hasSelectionChanged ? () => _confirmSelection(context, _getSelectedSet()) : null,
                    icon: Icon(Icons.check),
                    label: const Text('Confirm'),
                  ),
                ],
              )
            ],
          )),
    ));
  }

  void _initializeSelectionsState() {
    this._selectionsState = Map.from(widget.entitiesWithInitialSelection);
  }

  bool get _hasSelectionChanged =>
      !DeepCollectionEquality().equals(this._selectionsState, widget.entitiesWithInitialSelection);

  List<Widget> _buildSelectableChips() {
    return this
        ._selectionsState
        .entries
        .map((MapEntry<T, bool> entityWithState) => InputChip(
              label: Text(entityWithState.key.name),
              selected: entityWithState.value,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () => _updateLocalState(entityWithState.key),
            ))
        .toList();
  }

  void _closeOverlay(BuildContext context) {
    if (widget.onCloseModal != null) {
      widget.onCloseModal!();
      setState(() {
        _isClosingAfterButtonClick = true;
      });
    }
    Navigator.pop(context);
  }

  void _updateLocalState(T entity) {
    if (_selectionsState.containsKey(entity)) {
      setState(() {
        this._selectionsState.update(entity, (currentValue) => !currentValue);
      });
    }
  }

  void _confirmSelection(BuildContext context, Set<T> selectedEntities) {
    if (widget.onConfirmSelection != null) {
      widget.onConfirmSelection!(selectedEntities);
    }
    _closeOverlay(context);
  }

  Set<T> _getSelectedSet() =>
      this._selectionsState.entries.where((element) => element.value == true).map((e) => e.key).toSet();
}
