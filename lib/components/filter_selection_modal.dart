import 'package:flutter/material.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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
  static const tagCloudOuterPadding = 8.0;
  static const modalHeight = 500.0;
  static const tagCloudContainerHeight = 350.0;

  late final Map<T, bool> _selectionsState;
  bool _isClosingAfterButtonClick = false;

  late final Map<String, int> _alphabetElementsWithNearestIndices;
  late final AutoScrollController _chipsAutoScrollController;

  final charCodeA = 'A'.codeUnitAt(0);
  final charCodeZ = 'Z'.codeUnitAt(0);

  _FilterSelectionModalState() {
    // 48 is just a guess
    this._chipsAutoScrollController = AutoScrollController(axis: Axis.vertical, suggestedRowHeight: 48);
  }

  @override
  void initState() {
    super.initState();
    _initializeSelectionsState();
    this._alphabetElementsWithNearestIndices = _getAlphabetElementsWithNearestIndices();
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
      height: modalHeight,
      child: Padding(
          padding: EdgeInsets.all(tagCloudOuterPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter artists by tags',
                style: headlineLabelStyle,
              ),
              SizedBox(height: 16),
              _buildChipsCloud(context),
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

  Widget _buildChipsCloud(BuildContext context) {
    return Container(
      height: tagCloudContainerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background.withOpacity(0.4),
        border: Border.all(
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(4),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
            width: (MediaQuery.of(context).size.width - tagCloudOuterPadding * 2) * 0.85,
            child: ListView(
              controller: _chipsAutoScrollController,
              padding: EdgeInsets.all(2),
              children: [Wrap(spacing: 8.0, runSpacing: 2.0, children: _buildSelectableChips())],
            )),
        GestureDetector(
            onVerticalDragDown: (dragDownDetails) => _scrollAccordingToAlphabetDrag(dragDownDetails.localPosition.dy),
            // onVerticalDragUpdate: !_chipsAutoScrollController.isAutoScrolling
            //     ? (dragUpdateDetails) => _scrollAccordingToAlphabetDrag(dragUpdateDetails.localPosition.dy,
            //         duration: Duration(milliseconds: 100))
            //     : null,
            child: _buildAlphabetColumn()),
      ]),
    );
  }

  void _scrollAccordingToAlphabetDrag(double pixelPosition, {Duration? duration}) async {
    final alphabetIndex = (pixelPosition * 27 / tagCloudContainerHeight).round();
    if (duration != null) {
      _chipsAutoScrollController.scrollToIndex(alphabetIndex,
          preferPosition: AutoScrollPosition.begin, duration: duration);
    } else {
      _chipsAutoScrollController.scrollToIndex(alphabetIndex, preferPosition: AutoScrollPosition.begin);
    }
  }

  List<Widget> _buildSelectableChips() {
    String lastInitialLetter = '';
    return this._selectionsState.entries.map((MapEntry<T, bool> entityWithState) {
      final currentInitialLetter = _getInitialLetterForWord(entityWithState.key.name);
      if (currentInitialLetter != lastInitialLetter) {
        final currentAlphabetIndex = _getIndexForInitialLetter(currentInitialLetter);
        lastInitialLetter = currentInitialLetter;
        return AutoScrollTag(
            key: ValueKey(currentInitialLetter),
            controller: _chipsAutoScrollController,
            index: currentAlphabetIndex,
            child: _buildSingleChip(entityWithState.key.name, entityWithState.key, entityWithState.value));
      } else {
        return _buildSingleChip(entityWithState.key.name, entityWithState.key, entityWithState.value);
      }
    }).toList();
  }

  InputChip _buildSingleChip(String text, T entity, bool selected) =>
      InputChip(label: Text(text), selected: selected, onPressed: () => _updateLocalState(entity));

  Column _buildAlphabetColumn() => Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _alphabetElementsWithNearestIndices.entries
          .map((elementWithNearestIndex) => Container(
              padding: EdgeInsets.only(left: 2.0, right: 2.0),
              alignment: Alignment.center,
              width: (MediaQuery.of(context).size.width - tagCloudOuterPadding * 2) * 0.10,
              height: 12,
              color: Colors.black12,
              child: Text(elementWithNearestIndex.key, style: TextStyle(fontSize: 8))))
          .toList());

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

  //
  // Helpers for alphabet column
  //
  String _getInitialLetterForWord(String word) {
    final initialLetter = word.toUpperCase().substring(0, 1);
    if (initialLetter.codeUnitAt(0) >= charCodeA && initialLetter.codeUnitAt(0) <= charCodeZ) {
      return initialLetter;
    } else {
      return '#';
    }
  }

  Map<String, int> _getAlphabetElementsWithNearestIndices() {
    final alphabetElements = List<String>.generate(
      charCodeZ - charCodeA + 1,
      (index) => String.fromCharCode(charCodeA + index),
    );
    alphabetElements.insert(0, '#');

    final uniqueInitialLetters = _getUniqueInitialLetters(_selectionsState.keys.map((entity) => entity.name).toList());
    int lastOccurringIndex = 0;
    return Map.fromEntries(alphabetElements.map((element) {
      if (uniqueInitialLetters.contains(element)) {
        lastOccurringIndex = _getIndexForInitialLetter(element);
      }
      return MapEntry<String, int>(element, lastOccurringIndex);
    }));
  }

  Set<String> _getUniqueInitialLetters(List<String> words) {
    final uniqueInitialLetters = Set<String>();
    words.forEach((word) => uniqueInitialLetters.add(_getInitialLetterForWord(word)));
    return uniqueInitialLetters;
  }

  int _getIndexForInitialLetter(String letter) =>
      letter == '#' ? 0 : letter.toUpperCase().codeUnitAt(0) - charCodeA + 1;
}
