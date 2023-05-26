import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:moodtag/components/chip_cloud/chip_cloud_cursor.dart';
import 'package:moodtag/components/chip_cloud/chip_cloud_options.dart';

//
// FLowDelegate class taking care of painting the elements for the ChipCloud widget.
// Implements the algorithm to determine the visibility and positions of elements.
//
class ChipCloudDelegate extends FlowDelegate {
  final Size constraints;
  final ChipCloudOptions options;

  ChipCloudDelegate(this.constraints, {this.options = const ChipCloudOptions()});

  @override
  Size getSize(BoxConstraints _) => constraints;

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;

  @override
  void paintChildren(FlowPaintingContext context) {
    debugInfo('Constraints: ' + constraints.toString());
    debugInfo('Parent container size: ' + context.size.toString());

    if (context.childCount == 0) {
      debugInfo('No children - nothing to display.');
      return;
    }

    ChipCloudCursor cursor = ChipCloudCursor(options);
    debugInfo('First row: y=' + cursor.y.toString());
    debugInfo('First element height: ' + context.getChildSize(0)!.height.toString());

    if (_isElementOverflowingHeight(cursor.y, context.getChildSize(0)!.height)) {
      debugInfo('First element overflows the height of the container, not displaying any elements.');
      return;
    }

    cursor = _determinePositionsForMainElements(context, cursor);
    debugInfo('Skipped elements: ' + cursor.skippedElements.toString());

    if (options.showOverflowIndicator && cursor.didSkipElements) {
      final overflowIndicatorIndex = context.childCount - 1;
      Size overflowIndicatorSize = context.getChildSize(overflowIndicatorIndex)!;
      debugInfo('Overflow indicator size: ' + overflowIndicatorSize.toString());

      while (_isElementOverflowingHeight(cursor.y, overflowIndicatorSize.height)) {
        debugInfo('Indicator would overflow container height at y=${cursor.y}. Remove last displayed element.');
        cursor.removeLastDisplayedElementAndRepositionCursor();
      }

      while (_isElementOverflowingRowWidth(cursor.x, overflowIndicatorSize.width)) {
        debugInfo('Indicator would overflow row width at x=${cursor.x}. Remove last displayed element.');
        if (cursor.isAtStartOfRow) {
          break; // Do not show the indicator at all if it is wider than a row
        }
        cursor.removeLastDisplayedElementAndRepositionCursor();
      }

      if (!_isElementOverflowingRowWidth(cursor.x, overflowIndicatorSize.width)) {
        cursor.registerElementAtCursorPosition(overflowIndicatorIndex, overflowIndicatorSize.width);
      }
    }

    _paintElementsAsPositionedIn(cursor, context);
  }

  void _paintElementsAsPositionedIn(ChipCloudCursor cursor, FlowPaintingContext context) {
    debugInfo('Paint the elements.');
    for (MapEntry<int, Point<double>> pair in cursor.determinedElementPositions.entries) {
      context.paintChild(pair.key, transform: Matrix4.translationValues(pair.value.x, pair.value.y, 1));
    }
  }

  ChipCloudCursor _determinePositionsForMainElements(FlowPaintingContext context, ChipCloudCursor cursor) {
    for (int i = 0; i < _getMainElementCount(context); ++i) {
      final Size elementSize = context.getChildSize(i)!;
      debugInfo(
          '/// Element #${i.toString()} - x=${cursor.x.toString()} - width=${elementSize.width} - height=${elementSize.height}');

      bool isOverflowingRow = _isElementOverflowingRowWidth(cursor.x, elementSize.width);
      if (isOverflowingRow) {
        if (!cursor.isAtStartOfRow) {
          final previousElementSize = context.getChildSize(i - 1)!;
          final nextRowCursor = cursor.clone();
          nextRowCursor.moveToNextRow(previousElementSize.height);

          if (_isElementOverflowingHeight(nextRowCursor.y, elementSize.height)) {
            debugInfo(
                'Element #${i} would overflow the height constraint in the next row where y=${nextRowCursor.y.toString()}. Skip remaining elements');
            cursor.registerSkippedElements(_getMainElementCount(context) - i);
            break;
          } else {
            cursor = nextRowCursor;
            debugInfo('Next row - y=' + cursor.y.toString());
            isOverflowingRow = _isElementOverflowingRowWidth(cursor.x, elementSize.width);
          }
        }

        if (cursor.isAtStartOfRow && isOverflowingRow && options.skipLongElements) {
          debugInfo('Element #${i} does not fit in any row and will be skipped.');
          cursor.registerSkippedElements(1);
          continue;
        }
      }

      debugInfo('Element #${i} will be displayed at coordinates: x=${cursor.x}, y=${cursor.y}');
      cursor.registerElementAtCursorPosition(i, elementSize.width);
      cursor.moveToNextColumn(elementSize.width);
    }

    return cursor;
  }

  int _getMainElementCount(FlowPaintingContext context) =>
      options.showOverflowIndicator ? context.childCount - 1 : context.childCount;

  bool _isElementOverflowingRowWidth(double offsetX, double elementWidth) =>
      offsetX + elementWidth > constraints.width - options.padding.right;

  bool _isElementOverflowingHeight(double offsetY, double elementHeight) =>
      offsetY + elementHeight > constraints.height - options.padding.bottom;

  void debugInfo(String message) => options.debug ? print(message) : {};
}
