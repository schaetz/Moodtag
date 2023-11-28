import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/app_bar_context_data.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/main.dart';
import 'package:moodtag/model/blocs/app_bar/app_bar_bloc.dart';
import 'package:moodtag/model/blocs/spotify_auth/spotify_auth_bloc.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/events/spotify_events.dart';
import 'package:moodtag/navigation/routes.dart';

class MtAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const titleLabelStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);

  static const menuItemSpotifyImport = 'Spotify Import';
  static const menuItemLastFm = 'Last.fm';
  static const menuItemResetLibrary = 'Reset library';
  static const popupMenuItems = [menuItemSpotifyImport, menuItemLastFm, menuItemResetLibrary];
  static const double heightWithTabBar = 120;
  static const double heightWithoutTabBar = 60;

  final BuildContext context;
  late final TabController? tabController;

  MtAppBar(this.context) : super() {
    this.tabController = null;
  }

  MtAppBar.withMainTabBar(this.context, this.tabController);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppBarBloc>();
    final appBarContextData = context.read<AppBarContextData?>();
    final onBackButtonPressed = appBarContextData?.onBackButtonPressed ?? null;
    return AppBar(
      title: _buildTitle(context),
      actions: <Widget>[
        PopupMenuButton<String>(
          itemBuilder: (BuildContext itemBuilderContext) {
            return popupMenuItems.map((choice) => _buildPopupMenuItem(context, choice)).toList();
          },
          onSelected: (value) => _handlePopupMenuItemTap(context, value, bloc),
        ),
      ],
      automaticallyImplyLeading: onBackButtonPressed == null,
      leading: onBackButtonPressed != null ? BackButton(onPressed: () => onBackButtonPressed()) : null,
      bottom: tabController != null
          ? TabBar(controller: tabController, tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.library_music),
                text: 'Artists',
              ),
              Tab(
                icon: Icon(Icons.label),
                text: 'Tags',
              ),
            ])
          : null,
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

  static PopupMenuItem<String> _buildPopupMenuItem(BuildContext context, String choice) {
    return PopupMenuItem<String>(
      value: choice,
      child: Text(choice),
    );
  }

  static void _handlePopupMenuItemTap(BuildContext context, String value, AppBarBloc bloc) {
    final handleResetLibrary = () {
      bloc.add(ResetLibrary());
    };
    switch (value) {
      case menuItemSpotifyImport:
        if (context.read<SpotifyAuthBloc>().state.spotifyAuthCode == null) {
          Function redirectAfterAuth = () {
            Navigator.pop(context);
            Navigator.pushNamed(context, Routes.spotifyImport);
          };
          context.read<SpotifyAuthBloc>().add(RequestUserAuthorization(redirectAfterAuth: redirectAfterAuth));
          Navigator.of(context).pushNamed(Routes.spotifyAuth);
        } else {
          Navigator.of(context).pushNamed(Routes.spotifyImport);
        }
        break;
      case menuItemLastFm:
        Navigator.of(context).pushNamed(Routes.lastFmAccountManagement);
        break;
      case menuItemResetLibrary:
        DeleteDialog.openNew(context, deleteHandler: handleResetLibrary, entityToDelete: null, resetLibrary: true);
        break;
    }
  }
}
