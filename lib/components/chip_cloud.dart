import 'package:flutter/material.dart';

// WIP - not working as intended, because chips are always the size of the complete parent container
class ChipCloud extends StatelessWidget {
  final List<String> captions;
  final Size constraints;

  const ChipCloud({super.key, required this.captions, required this.constraints});

  @override
  Widget build(BuildContext context) {
    print('Constraints: ' + constraints.toString());
    return Flow(
      delegate: ChipCloudDelegate(constraints),
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
  final bool leaveOutLongElements = true;
  final Size constraints;
  final int elementSpacing = 0;
  final int rowSpacing = 0;

  ChipCloudDelegate(this.constraints);

  @override
  void paintChildren(FlowPaintingContext context) {
    print('Parent container size: ' + context.size.toString());

    int row = 0;
    int column = 0;
    double x = 0;
    double y = 0;
    bool isOverflowingY = context.childCount > 0 && _isElementOverflowingY(y, context.getChildSize(0)!.height);

    for (int i = 0; i < context.childCount; ++i) {
      print('/// el ' + i.toString());
      print('x=' + x.toString());
      final elementHeight = context.getChildSize(i)!.height;

      final elementWidth = context.getChildSize(i)!.width;
      print('Element size: ' + context.getChildSize(i).toString());
      bool isOverflowingRow = _isElementOverflowingRow(x, elementWidth);
      bool leaveOutElement = false;

      if (isOverflowingRow) {
        if (column > 0) {
          row++;
          y += rowSpacing + context.getChildSize(i - 1)!.height;
          column = 0;
          x = 0;
          print('row++ - x=0, y=' + y.toString());
          isOverflowingRow = _isElementOverflowingRow(x, elementWidth);
          isOverflowingY = _isElementOverflowingY(y, elementHeight);
        }
        if (isOverflowingY || column == 0 && isOverflowingRow && leaveOutLongElements) {
          leaveOutElement = true;
          print('Leave out element');
        }
      }

      context.paintChild(i, transform: Matrix4.translationValues(x.toDouble(), y.toDouble(), leaveOutElement ? 0 : 1));
      column++;
      x += elementSpacing + elementWidth;
    }
  }

  bool _isElementOverflowingRow(double offsetX, double elementWidth) => offsetX + elementWidth > constraints.width;

  bool _isElementOverflowingY(double offsetY, double elementHeight) => offsetY + elementHeight > constraints.height;

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}
