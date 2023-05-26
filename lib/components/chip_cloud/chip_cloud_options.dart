import 'package:flutter/widgets.dart';

//
// Configuration for the chip cloud algorithm.
//
class ChipCloudOptions {
  final bool showOverflowIndicator;
  final bool skipLongElements;
  final double elementSpacing;
  final double rowSpacing;
  final EdgeInsets padding;
  final bool debug;

  const ChipCloudOptions(
      {this.showOverflowIndicator = true,
      this.skipLongElements = true,
      this.elementSpacing = 0.0,
      this.rowSpacing = 0.0,
      this.padding = EdgeInsets.zero,
      this.debug = false});
}
