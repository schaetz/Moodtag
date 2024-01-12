import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/app/main.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/shared/widgets/main_layout/app_bar_context_data.dart';

import 'colored_tab_bar.dart';

class MtAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const titleLabelStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);

  static const double heightWithTabBar = 120;
  static const double heightWithoutTabBar = 46;

  final BuildContext context;
  late final TabController? tabController;

  MtAppBar(this.context) : super() {
    this.tabController = null;
  }

  MtAppBar.withMainTabBar(this.context, this.tabController);

  @override
  Widget build(BuildContext context) {
    final appBarContextData = context.read<AppBarContextData?>();
    final onBackButtonPressed = appBarContextData?.onBackButtonPressed ?? null;
    return AppBar(
      title: _buildTitle(context),
      actions: <Widget>[
        IconButton(icon: Icon(Icons.settings), onPressed: () => Navigator.of(context).pushNamed(Routes.appSettings))
      ],
      automaticallyImplyLeading: onBackButtonPressed == null,
      leading: onBackButtonPressed != null ? BackButton(onPressed: () => onBackButtonPressed()) : null,
      bottom: tabController != null ? buildTabBar() : null,
    );
  }

  @override
  Size get preferredSize =>
      tabController == null ? Size.fromHeight(heightWithoutTabBar) : Size.fromHeight(heightWithTabBar);

  static GestureDetector _buildTitle(BuildContext context) {
    return GestureDetector(
      child: Text(
        MoodtagApp.appTitle,
        style: titleLabelStyle,
      ),
      onTap: () => {
        if (Navigator.of(context).canPop())
          {Navigator.of(context).popUntil(ModalRouteExt.withName(Routes.libraryMainScreen))}
      },
    );
  }

  ColoredTabBar buildTabBar() {
    return ColoredTabBar(
        color: Theme.of(context).colorScheme.primaryContainer,
        tabBar: TabBar(controller: tabController, tabs: const <Widget>[
          Tab(
            icon: Icon(Icons.library_music),
            text: 'Artists',
          ),
          Tab(
            icon: Icon(Icons.label),
            text: 'Tags',
          ),
        ]));
  }
}
