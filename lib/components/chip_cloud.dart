import 'package:flutter/material.dart';

// WIP - not working as intended, because chips are always the size of the complete parent container
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
    debug ? print('Constraints: ' + constraints.toString()) : {};
    return Flow(
      delegate: ChipCloudDelegate(constraints, leaveOutLongElements, elementSpacing, rowSpacing, padding, debug: debug),
      children: captions.map<Widget>((String caption) => _buildElement(caption)).toList(),
    );
  }

  Widget _buildElement(String caption) {
    return InputChip(
      label: Text(caption),
      labelStyle: TextStyle(fontSize: 14.0),
    );
  }
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
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) => constraints.loosen();

  @override
  void paintChildren(FlowPaintingContext context) {
    print('Parent container size: ' + context.size.toString());

    final leftPadding = padding?.left ?? 0;
    final rightPadding = padding?.right ?? 0;
    final topPadding = padding?.top ?? 0;
    final bottomPadding = padding?.bottom ?? 0;

    int row = 0;
    int column = 0;
    double x = leftPadding;
    double y = topPadding;
    debug ? print('row 0 - y=' + y.toString()) : {};
    bool isOverflowingY =
        context.childCount > 0 && _isElementOverflowingY(y, context.getChildSize(0)!.height, bottomPadding);
    if (isOverflowingY) {
      return;
    }

    for (int i = 0; i < context.childCount; ++i) {
      debug ? print('/// el ' + i.toString()) : {};
      debug ? print('x=' + x.toString()) : {};
      final elementHeight = context.getChildSize(i)!.height;

      final elementWidth = context.getChildSize(i)!.width;
      debug ? print('Element size: ' + context.getChildSize(i).toString()) : {};
      bool isOverflowingRow = _isElementOverflowingRow(x, elementWidth, rightPadding);

      if (isOverflowingRow) {
        if (column > 0) {
          row++;
          y += rowSpacing + context.getChildSize(i - 1)!.height;
          column = 0;
          x = leftPadding;
          debug ? print('row++ - y=' + y.toString()) : {};
          isOverflowingRow = _isElementOverflowingRow(x, elementWidth, rightPadding);
          if (_isElementOverflowingY(y, elementHeight, bottomPadding)) {
            break;
          }
        }
        if (column == 0 && isOverflowingRow && leaveOutLongElements) {
          debug ? print('Leave out element') : {};
          continue;
        }
      }

      context.paintChild(i, transform: Matrix4.translationValues(x.toDouble(), y.toDouble(), 1));
      column++;
      x += elementSpacing + elementWidth;
    }
  }

  bool _isElementOverflowingRow(double offsetX, double elementWidth, double rightPadding) =>
      offsetX + elementWidth > constraints.width - rightPadding;

  bool _isElementOverflowingY(double offsetY, double elementHeight, double bottomPadding) =>
      offsetY + elementHeight > constraints.height - bottomPadding;

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}
