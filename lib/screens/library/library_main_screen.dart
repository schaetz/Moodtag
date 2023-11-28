import 'package:flutter/material.dart';
import 'package:moodtag/components/mt_main_scaffold.dart';
import 'package:moodtag/screens/library/artists_list_screen.dart';
import 'package:moodtag/screens/library/tags_list_screen.dart';

class LibraryMainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LibraryMainScreenState();
}

/// [AnimationController]s can be created with `vsync: this` because of [TickerProviderStateMixin].
/// See https://api.flutter.dev/flutter/material/TabBar-class.html
class _LibraryMainScreenState extends State<LibraryMainScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MtMainScaffold(
        scaffoldKey: _scaffoldKey,
        tabController: _tabController,
        pageWidget: TabBarView(
          controller: _tabController,
          children: [ArtistsListScreen(_scaffoldKey), TagsListScreen(_scaffoldKey)],
        ));
  }
}
