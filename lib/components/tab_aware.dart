import 'package:flutter/material.dart';

/// An interface for widgets that are aware of the selected tab
/// of their parent TabView
abstract mixin class TabAware {
  void registerAsTabControllerListener(TabController tabController, int index) {
    tabController.addListener(() {
      if (tabController.index == index) {
        didBecomeActiveTab();
      } else if (tabController.previousIndex == index) {
        didBecomeInactiveTab();
      }
    });
  }

  void didBecomeActiveTab();
  void didBecomeInactiveTab();
}
