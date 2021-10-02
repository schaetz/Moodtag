import 'package:flutter/material.dart';

import 'package:moodtag/main.dart';

class MtAppBar extends AppBar {

  static const titleLabelStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);

  MtAppBar() : super(title: GestureDetector(
    child: Text(
      MoodtagApp.appTitle,
      style: titleLabelStyle,
    ),
    //onTap: () => {} TODO
  ));

}