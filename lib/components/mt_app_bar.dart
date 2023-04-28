import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/main.dart';
import 'package:moodtag/model/blocs/app_bar/app_bar_bloc.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/screens/spotify_import/import_flow_state.dart';

class MtAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const titleLabelStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);

  static const menuItemSpotifyImport = 'Spotify Import';
  static const menuItemLastFmImport = 'LastFm Import';
  static const menuItemResetLibrary = 'Reset library';
  static const popupMenuItems = [menuItemSpotifyImport, menuItemLastFmImport, menuItemResetLibrary];
  static const double height = 60;

  final BuildContext context;
  final bool forceBackButton;

  MtAppBar(this.context, {this.forceBackButton = false}) : super();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppBarBloc>();
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
      leading: forceBackButton ? BackButton(onPressed: () => context.flow<ImportFlowState>().complete()) : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);

  static GestureDetector _buildTitle(BuildContext context) {
    return GestureDetector(
      child: Text(
        MoodtagApp.appTitle,
        style: titleLabelStyle,
      ),
      onTap: () => {
        if (Navigator.of(context).canPop())
          {Navigator.of(context).popUntil(ModalRouteExt.withNames(Routes.artistsList, Routes.tagsList))}
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
        Navigator.of(context).pushNamed(Routes.spotifyImport);
        break;
      case menuItemLastFmImport:
        Navigator.of(context).pushNamed(Routes.lastFmImport);
        break;
      case menuItemResetLibrary:
        DeleteDialog.openNew(context, deleteHandler: handleResetLibrary, entityToDelete: null, resetLibrary: true);
        break;
    }
  }
}
