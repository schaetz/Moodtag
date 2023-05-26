import 'dart:math';

import 'package:flutter/material.dart';

class ChipCloud extends StatelessWidget {
  final List<String> captions;
  final Size constraints;
  final bool leaveOutLongElements;
  final int elementSpacing;
  final int rowSpacing;
  final EdgeInsets? padding;
  final debug;

  const ChipCloud(
      {super.key,
      required this.captions,
      required this.constraints,
      this.leaveOutLongElements = true,
      this.elementSpacing = 0,
      this.rowSpacing = 0,
      this.padding,
      this.debug = false});

  @override
  Widget build(BuildContext context) {
    debugInfo('Constraints: ' + constraints.toString());
    return Flow(
        delegate:
            ChipCloudDelegate(constraints, leaveOutLongElements, elementSpacing, rowSpacing, padding, debug: debug),
        children: _buildElements());
  }

  List<Widget> _buildElements() {
    final elements = captions.map<Widget>((String caption) => _buildElement(caption)).toList();
    final overflowIndicator = _buildElement('...', backgroundColor: Colors.white);
    elements.add(overflowIndicator);
    return elements;
  }

  Widget _buildElement(String caption, {Color? backgroundColor}) {
    return Chip(
      label: Text(caption),
      labelStyle: TextStyle(fontSize: 14.0),
      backgroundColor: backgroundColor,
    );
  }

  void debugInfo(String message) => debug ? print(message) : {};
}

class ChipCloudDelegate extends FlowDelegate {
  final Size constraints;
  final bool leaveOutLongElements;
  final int elementSpacing;
  final int rowSpacing;
  final EdgeInsets? padding;
  final debug;

  ChipCloudDelegate(this.constraints, this.leaveOutLongElements, this.elementSpacing, this.rowSpacing, this.padding,
      {this.debug = false});

  @override
  Size getSize(BoxConstraints _) => constraints;

  @override
  void paintChildren(FlowPaintingContext context) {
    print('Parent container size: ' + context.size.toString());

    final leftPadding = padding?.left ?? 0;
    final rightPadding = padding?.right ?? 0;
    final topPadding = padding?.top ?? 0;
    final bottomPadding = padding?.bottom ?? 0;

    int row = 0;
    int column = 0;
    Point<double> cursor = Point(leftPadding, topPadding);
    Point<double> addElementWidthAndSpacing(Point<double> cursor, double elementWidth) =>
        cursor + Point(elementWidth + elementSpacing, 0);
    Point<double> moveToNextRow(Point<double> cursor, double elementHeight) =>
        Point(leftPadding, cursor.y + elementHeight + rowSpacing);

    debugInfo('row 0 - y=' + cursor.y.toString());
    debugInfo('First element height: ' + context.getChildSize(0)!.height.toString());
    // Do not display anything if even the first element overflows the height of the container
    bool isOverflowingY =
        context.childCount > 0 && _isElementOverflowingY(cursor.y, context.getChildSize(0)!.height, bottomPadding);
    if (isOverflowingY) {
      return;
    }

    final determinedPositions = Map<int, Point<double>>();
    int missingElements = 0;
    List<int> displayedElementIndices = [];

    // Iterate over all children except the last one, which is the overflow indicator (shown when elements are missing)
    for (int i = 0; i < context.childCount - 1; ++i) {
      debugInfo('/// el ' + i.toString());
      debugInfo('x=' + cursor.x.toString());
      final elementHeight = context.getChildSize(i)!.height;

      final elementWidth = context.getChildSize(i)!.width;
      debugInfo('Element size: ' + context.getChildSize(i).toString());
      bool isOverflowingRow = _isElementOverflowingRow(cursor.x, elementWidth, rightPadding);

      if (isOverflowingRow) {
        // Element will overflow the current row if attached at the end: Move it to the next row
        if (column > 0) {
          // Try moving to the next row
          final cursorLookahead = moveToNextRow(cursor, context.getChildSize(i - 1)!.height);
          // Element will also overflow the height of the container if moved to the next line:
          // Stop adding elements and keep the cursor where it is for the overflow indicator
          if (_isElementOverflowingY(cursorLookahead.y, elementHeight, bottomPadding)) {
            debugInfo('Final overflow - y=' + cursorLookahead.y.toString());
            missingElements += context.childCount - i - 1;
            break;
          } else {
            // Moving to the next row works
            debugInfo('row++ - y=' + cursor.y.toString());
            cursor = cursorLookahead;
            isOverflowingRow = _isElementOverflowingRow(cursor.x, elementWidth, rightPadding);
            ++row;
            column = 0;
          }
        }
        // Element is the first in the (new) row and still overflows the width of the container:
        // Leave it out or allow horizontal overflow
        if (column == 0 && isOverflowingRow && leaveOutLongElements) {
          debugInfo('Leave out element');
          ++missingElements;
          continue;
        }
      }

      // Register determined position for element i
      determinedPositions.putIfAbsent(i, () => Point(cursor.x, cursor.y));
      displayedElementIndices.add(i);
      column++;
      cursor = addElementWidthAndSpacing(cursor, elementWidth);
    }

    // Show overflow indicator if any elements have been left out
    debugInfo('Missing elements: ' + missingElements.toString());
    if (missingElements > 0) {
      final overflowIndicatorIndex = context.childCount - 1;
      Size overflowIndicatorSize = context.getChildSize(overflowIndicatorIndex)!;
      debugInfo('Overflow indicator size: ' + overflowIndicatorSize.toString());
      // Indicator would overflow height of container:
      // Remove elements so that the indicator can be the last element in the line before
      while (_isElementOverflowingY(cursor.y, overflowIndicatorSize.height, bottomPadding)) {
        debugInfo('Indicator would overflow container height: ' + cursor.y.toString());
        cursor = _removeLastElementAndUpdateCoordinates(
            cursor, context, determinedPositions, displayedElementIndices, addElementWidthAndSpacing);
        --row;
      }

      // Indicator would overflow row: Remove elements from the row until it fits
      while (_isElementOverflowingRow(cursor.x, overflowIndicatorSize.width, rightPadding)) {
        debugInfo('Indicator would overflow row: ' + cursor.x.toString());
        // If the indicator is wider than a complete row, do not show it
        if (column == 0) {
          break;
        }
        cursor = _removeLastElementAndUpdateCoordinates(
            cursor, context, determinedPositions, displayedElementIndices, addElementWidthAndSpacing);
        --column;
      }
      determinedPositions.putIfAbsent(overflowIndicatorIndex, () => cursor);
    }

    for (MapEntry<int, Point<double>> pair in determinedPositions.entries) {
      context.paintChild(pair.key, transform: Matrix4.translationValues(pair.value.x, pair.value.y, 1));
    }
  }

  Point<double> _removeLastElementAndUpdateCoordinates(
    Point<double> cursor,
    FlowPaintingContext context,
    Map<int, Point<double>> determinedPositions,
    List<int> displayedElementIndices,
    Point<double> Function(Point<double>, double) addElementWidthAndSpacing,
  ) {
    final lastElementIndex = displayedElementIndices.removeLast();
    determinedPositions.remove(lastElementIndex);
    final indexBefore = displayedElementIndices.last;
    final elementBeforePosition = determinedPositions[indexBefore]!;
    final elementBeforeSize = context.getChildSize(indexBefore)!;
    Point<double> updatedCursor = addElementWidthAndSpacing(elementBeforePosition, elementBeforeSize.width);
    return updatedCursor;
  }

  bool _isElementOverflowingRow(double offsetX, double elementWidth, double rightPadding) =>
      offsetX + elementWidth > constraints.width - rightPadding;

  bool _isElementOverflowingY(double offsetY, double elementHeight, double bottomPadding) =>
      offsetY + elementHeight > constraints.height - bottomPadding;

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;

  void debugInfo(String message) => debug ? print(message) : {};
}
