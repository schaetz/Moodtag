import 'dart:math';

import 'package:moodtag/components/chip_cloud/chip_cloud_options.dart';

//
// Represents a state in the algorithm to determine which elements fit in a row
// and which elements need to be skipped to avoid an overflow.
//
// The _position property determines where the next element will be positioned
// (if it does not cause an overflow).
//
class ChipCloudCursor {
  final ChipCloudOptions options;

  int _row;
  int _column;
  Point<double> _position;
  Map<int, Point<double>> _determinedElementPositions;
  Map<int, int> _elementsPerRow;
  List<int> _displayedElementsIndices;
  List<double> _displayedElementsWidth;
  int _skippedElements;

  int get column => _column;
  Map<int, Point<double>> get determinedElementPositions => _determinedElementPositions;
  int get skippedElements => _skippedElements;

  bool get isAtStartOfRow => _column == 0;
  bool get didSkipElements => _skippedElements > 0;

  double get x => _position.x;
  double get y => _position.y;

  ChipCloudCursor(this.options)
      : _row = 0,
        _column = 0,
        _position = Point(options.padding.left, options.padding.top),
        _determinedElementPositions = {},
        _elementsPerRow = {},
        _displayedElementsIndices = [],
        _displayedElementsWidth = [],
        _skippedElements = 0;

  ChipCloudCursor.initializeWith(
      this.options,
      this._row,
      this._column,
      this._position,
      this._determinedElementPositions,
      this._elementsPerRow,
      this._displayedElementsIndices,
      this._displayedElementsWidth,
      this._skippedElements);

  ChipCloudCursor clone() {
    return ChipCloudCursor.initializeWith(
        options,
        _row,
        _column,
        Point(this.x, this.y),
        Map.from(_determinedElementPositions),
        Map.from(_elementsPerRow),
        List.from(_displayedElementsIndices),
        List.from(_displayedElementsWidth),
        _skippedElements);
  }

  void moveToNextColumn(double currentElementWidth) {
    _position = _position + Point(currentElementWidth + options.elementSpacing, 0);
    _column++;
  }

  void moveToNextRow(double previousElementHeight) {
    _position = Point(options.padding.left, _position.y + previousElementHeight + options.rowSpacing);
    _column = 0;
    _row++;
  }

  void registerElementAtCursorPosition(int elementIndex, double elementWidth) {
    _determinedElementPositions.putIfAbsent(elementIndex, () => Point(_position.x, _position.y));
    _displayedElementsIndices.add(elementIndex);
    _displayedElementsWidth.add(elementWidth);
    _elementsPerRow.update(_row, (count) => count + 1, ifAbsent: () => 1);
  }

  void registerSkippedElements(int count) {
    _skippedElements += count;
  }

  void removeLastDisplayedElementAndRepositionCursor() {
    final lastElementIndex = _displayedElementsIndices.removeLast();
    _determinedElementPositions.remove(lastElementIndex);
    _displayedElementsWidth.removeLast();

    if (_elementsPerRow[_row] == 1) {
      _elementsPerRow.remove(_row);
      _row--;
      _column = _elementsPerRow[_row] ?? 0;
    } else {
      _elementsPerRow.update(_row, (count) => count - 1);
      _column--;
    }
    _skippedElements++;

    final nextToLastElementIndex = _displayedElementsIndices.last;
    final nextToLastElementPosition = _determinedElementPositions[nextToLastElementIndex]!;
    final nextToLastElementWidth = _displayedElementsWidth.last;

    _position = nextToLastElementPosition + Point(nextToLastElementWidth + options.elementSpacing, 0);
  }
}
