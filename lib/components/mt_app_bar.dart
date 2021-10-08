import 'package:flutter/material.dart';

import 'package:moodtag/main.dart';
import 'package:moodtag/navigation/routes.dart';

class MtAppBar extends AppBar {

  static const titleLabelStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);

  MtAppBar(BuildContext context) : super(title: GestureDetector(
    child: Text(
      MoodtagApp.appTitle,
      style: titleLabelStyle,
    ),
    onTap: () => Navigator.of(context).popUntil(ModalRoute.withName(Routes.initialRoute))
  ));

}