import 'package:flutter/material.dart';
import 'package:moodtag/model/database/join_data_classes.dart';

class FilterSelectionModal<T extends DataClassWithEntityName> extends StatefulWidget {
  final Map<T, bool> entitiesWithInitialSelection;
  final Function(Set<T>)? onConfirmSelection;
  final Function? onCloseModal;

  const FilterSelectionModal(
      {required this.entitiesWithInitialSelection, this.onConfirmSelection = null, this.onCloseModal = null});

  @override
  State<StatefulWidget> createState() => _FilterSelectionModalState<T>();
}

class _FilterSelectionModalState<T extends DataClassWithEntityName> extends State<FilterSelectionModal<T>> {
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
    return SizedBox(
      height: 500,
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background.withOpacity(0.4),
                    border: Border.all(
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(4),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [Wrap(spacing: 8.0, runSpacing: 2.0, children: _buildSelectableChips())],
                  )),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _confirmSelection(context, {}),
                    icon: Icon(Icons.filter_list_off),
                    label: Text('Clear filters'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _confirmSelection(context, _getSelectedSet()),
                    icon: Icon(Icons.check),
                    label: const Text('Confirm'),
                  ),
                ],
              )
            ],
          )),
    );
  }

  void _initializeSelectionsState() {
    this._selectionsState = Map.from(widget.entitiesWithInitialSelection);
  }

  List<Widget> _buildSelectableChips() {
    return this
        ._selectionsState
        .entries
        .map((MapEntry<T, bool> entityWithState) => InputChip(
              label: Text(entityWithState.key.name),
              selected: entityWithState.value,
              onPressed: () => _updateLocalState(entityWithState.key),
            ))
        .toList();
  }

  void _closeModal(BuildContext context) {
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
    _closeModal(context);
  }

  Set<T> _getSelectedSet() =>
      this._selectionsState.entries.where((element) => element.value == true).map((e) => e.key).toSet();
}
