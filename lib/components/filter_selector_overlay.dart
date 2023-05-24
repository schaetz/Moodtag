import 'package:flutter/material.dart';

class FilterSelectorOverlay extends StatefulWidget {
  final Map<String, bool> entitiesWithInitialSelection;
  final Function? onClose;

  const FilterSelectorOverlay({required this.entitiesWithInitialSelection, this.onClose = null});

  @override
  State<StatefulWidget> createState() => _FilterSelectorOverlayState();
}

class _FilterSelectorOverlayState extends State<FilterSelectorOverlay> {
  static const headlineLabelStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);

  late final Map<String, bool> _selectionsState;

  @override
  void initState() {
    super.initState();
    _initializeSelectionsState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
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
                  height: 400,
                  child: ListView(
                    children: [Wrap(spacing: 8.0, runSpacing: 2.0, children: _buildSelectableChips())],
                  ))
            ],
          )),
    ));
  }

  void _initializeSelectionsState() {
    this._selectionsState = widget.entitiesWithInitialSelection;
  }

  List<Widget> _buildSelectableChips() {
    return this
        ._selectionsState
        .entries
        .map((MapEntry<String, bool> entityWithState) => InputChip(
              label: Text(entityWithState.key),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () => _updateStateOfEntity(entityWithState.key),
            ))
        .toList();
  }

  void _updateStateOfEntity(String entityName) {
    if (_selectionsState.containsKey(entityName)) {
      this._selectionsState.putIfAbsent(entityName, () => !_selectionsState[entityName]!);
    }
  }
}
