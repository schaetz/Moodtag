import 'package:flutter/material.dart';

import 'mt_app_bar.dart';

class MtMainScaffold extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget pageWidget;
  final TabController? tabController;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  MtMainScaffold(
      {required this.scaffoldKey,
      required this.pageWidget,
      this.tabController,
      this.floatingActionButton,
      this.bottomNavigationBar});

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
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
