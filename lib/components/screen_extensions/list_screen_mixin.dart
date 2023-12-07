import 'package:flutter/material.dart';

/// A mixin for screens with a list view where other elements need to access
/// the constraints of the built list screen to determine their position
mixin ListViewConstraintsUser {
  final GlobalKey listViewKey = GlobalKey();
  Offset? listViewLowerLeftCorner;
  RenderBox? listViewRenderBox;

  bool get canUseListScreenConstraints => listViewLowerLeftCorner != null && listViewRenderBox != null;

  /// Determines the constraints of the ListView (the widget which was assigned the listViewKey);
  /// should be called from the initState() method of the widget state and be framed by
  /// WidgetsBinding.instance.addPostFrameCallback((_) { ... }) to wait until the widget using
  /// the ListView was built.
  void setListViewConstraints() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (listViewKey.currentContext != null) {
        listViewRenderBox = listViewKey.currentContext?.findRenderObject() as RenderBox;
        listViewLowerLeftCorner = listViewRenderBox!.localToGlobal(Offset(0, listViewRenderBox!.size.height));
      }
    });
  }
}
