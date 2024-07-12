import 'package:flutter/material.dart';

/// A widget that displays a placeholder as long as a given condition is unfulfilled,
/// and a widget built from a given function if all conditions are fulfilled.
/// Can be extended to customize the behavior.
///
/// C is the return type of a condition. In the most simple case, it is a boolean.
/// D is the type of the data passed on to the buildOnSuccess function.
class ConditionalDisplayWrapper<C, D> extends StatelessWidget {
  static const errorLabelStyle = TextStyle(fontSize: 18.0, color: Colors.black);

  final List<C Function()> conditions;
  final Widget Function(List<D>) buildOnSuccess;
  final String captionForError;

  const ConditionalDisplayWrapper(
      {super.key,
      required this.conditions,
      required this.buildOnSuccess,
      this.captionForError = 'Could not obtain data'});

  @override
  Widget build(BuildContext context) {
    return buildWidgetBasedOnConditions();
  }

  Widget buildWidgetBasedOnConditions() {
    if (hasErrorCondition()) {
      return buildErrorPlaceholder();
    } else if (hasUnfulfilledCondition()) {
      return buildConditionUnfulfilledPlaceholder();
    }
    return buildOnSuccess([]);
  }

  Widget buildConditionUnfulfilledPlaceholder() {
    return Align(alignment: Alignment.center, child: CircularProgressIndicator());
  }

  Widget buildErrorPlaceholder() {
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(Icons.error),
              style: errorLabelStyle,
            ),
            TextSpan(text: " Error: " + captionForError, style: errorLabelStyle),
          ],
        ),
      ),
    );
  }

  // bool checkAllConditionsFulfilled() =>
  //     !conditions.any((conditionFunc) => conditionFunc() == null || conditionFunc() == false);

  bool hasErrorCondition() => conditions.any((conditionFunc) => conditionFunc() == null);

  bool hasUnfulfilledCondition() => !conditions.any((conditionFunc) => conditionFunc() == false);
}
