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
        onSelected: _handlePopupMenuItemTap,
        itemBuilder: (BuildContext context) {
          return popupMenuItems.map((choice) => _buildPopupMenuItem(choice)).toList();
        },
      ),
    ],
  );

  static GestureDetector _buildTitle(BuildContext context) {
    return GestureDetector(
      child: Text(
        MoodtagApp.appTitle,
        style: titleLabelStyle,
      ),
      onTap: () => Navigator.of(context).popUntil(ModalRoute.withName(Routes.initialRoute))
    );
  }

  static PopupMenuItem<String> _buildPopupMenuItem(String choice) {
    return PopupMenuItem<String>(
      value: choice,
      child: Text(choice),
      onTap: () => _handlePopupMenuItemTap(choice),
    );
  }

  static void _handlePopupMenuItemTap(String value) {
    switch (value) {
      case 'Spotify Import':
        // TODO
        print('Navigate to Spotify Import');
        break;
    }
  }

}