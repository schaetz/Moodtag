import 'package:flutter/material.dart';
import 'package:moodtag/components/chip_cloud/chip_cloud_options.dart';

import 'chip_cloud_delegate.dart';

//
// A widget that arranges chips or similar widgets in a multi-line layout,
// similar to the Wrap widget, but makes sure that the layout remains
// within the given constraints by hiding chips that cause an overflow.
//
// Can optionally add a final element that indicates that some elements
// have been left out.
//
class ChipCloud<T> extends StatelessWidget {
  final List<T> data;
  final Size constraints;
  final ChipCloudOptions options;

  const ChipCloud({super.key, required this.data, required this.constraints, this.options = const ChipCloudOptions()});

  @override
  Widget build(BuildContext context) {
    return Flow(delegate: ChipCloudDelegate(constraints, options: options), children: _buildElements());
  }

  List<Widget> _buildElements() {
    final elements = data.map<Widget>((T dataSet) => buildElement<T>(dataSet)).toList();
    if (options.showOverflowIndicator == true) {
      elements.add(buildOverflowIndicator());
    }
    return elements;
  }

  Widget buildElement<T>(T dataSet) {
    return Chip(
      label: Text(T == String ? dataSet as String : dataSet.toString()),
      labelStyle: TextStyle(fontSize: 14.0),
    );
  }

  Widget buildOverflowIndicator() {
    return buildElement<String>('...');
  }
}
