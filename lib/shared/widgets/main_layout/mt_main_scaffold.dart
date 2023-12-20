import 'package:flutter/material.dart';

import 'mt_app_bar.dart';

class MtMainScaffold extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget pageWidget;
  final TabController? tabController;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  MtMainScaffold({
    required this.scaffoldKey,
    required this.pageWidget,
    this.tabController,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  State<MtMainScaffold> createState() => _MtMainScaffoldState();
}

class _MtMainScaffoldState extends State<MtMainScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget.scaffoldKey,
        appBar: MtAppBar.withMainTabBar(context, widget.tabController),
        body: widget.pageWidget,
        bottomNavigationBar: widget.bottomNavigationBar,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained);
  }
}
