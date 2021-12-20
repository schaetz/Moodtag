import 'package:flutter/material.dart';

import 'package:moodtag/main.dart';
import 'package:moodtag/navigation/routes.dart';

class MtAppBar extends AppBar {

  static const titleLabelStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);
  static const popupMenuItems = ['Spotify Import'];

  MtAppBar(BuildContext context) : super(
    title: _buildTitle(context),
    actions: <Widget>[
      PopupMenuButton<String>(
        itemBuilder: (BuildContext itemBuilderContext) {
          return popupMenuItems.map((choice) => _buildPopupMenuItem(context, choice)).toList();
        },
        onSelected: (value) => _handlePopupMenuItemTap(context, value),
      ),
    ]
  );

  static GestureDetector _buildTitle(BuildContext context) {
    return GestureDetector(
      child: Text(
        MoodtagApp.appTitle,
        style: titleLabelStyle,
      ),
      onTap: () => Navigator.of(context).popUntil(ModalRoute.withName(Routes.initialRoute)),
    );
  }

  static PopupMenuItem<String> _buildPopupMenuItem(BuildContext context, String choice) {
    return PopupMenuItem<String>(
      value: choice,
      child: Text(choice),
    );
  }

  static void _handlePopupMenuItemTap(BuildContext context, String value) {
    switch (value) {
      case 'Spotify Import':
        Navigator.of(context).pushNamed(Routes.spotifyImport);
        break;
    }
  }

}