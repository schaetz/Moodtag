import 'package:flutter/material.dart';

import 'mt_app_bar.dart';

class MtMainScaffold extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget pageWidget;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  MtMainScaffold(
      {required this.scaffoldKey, required this.pageWidget, this.floatingActionButton, this.bottomNavigationBar});

  @override
  State<MtMainScaffold> createState() => _MtMainScaffoldState();
}

/// [AnimationController]s can be created with `vsync: this` because of [TickerProviderStateMixin].
/// See https://api.flutter.dev/flutter/material/TabBar-class.html
class _MtMainScaffoldState extends State<MtMainScaffold> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: MtAppBar.withMainTabBar(context, _tabController),
      body: widget.pageWidget,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
