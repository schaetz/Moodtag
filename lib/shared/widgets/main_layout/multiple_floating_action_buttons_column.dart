import 'package:flutter/widgets.dart';

/// Deprecated - No longer in use
class MultipleFloatingActionButtonsColumn extends StatelessWidget {
  static const gapElement = SizedBox(
    height: 16,
  );
  late final List<Widget> children;

  MultipleFloatingActionButtonsColumn({super.key, required List<Widget> children}) {
    this.children = _insertGapsBetweenChildren(children);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: this.children,
    );
  }

  List<Widget> _insertGapsBetweenChildren(List<Widget> childrenWithoutGaps) {
    List<Widget> childrenWithGaps = [];
    bool firstElement = true;
    childrenWithoutGaps.forEach((child) {
      if (!firstElement) {
        childrenWithGaps.add(gapElement);
      }
      firstElement = false;
      childrenWithGaps.add(child);
    });
    return childrenWithGaps;
  }
}
