/*
 * Copyright 2021 Stefan Schätz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MoodtagApp());
}

class MoodtagApp extends StatefulWidget {
  static const appTitle = 'Moodtag';

  MoodtagApp({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MoodtagApp> {
  @override
  Widget build(BuildContext context) {
    return Provider<MoodtagBloc>(
        create: (_) => MoodtagBloc(),
        dispose: (_, bloc) => bloc.close(),
        child: MaterialApp(
            title: MoodtagApp.appTitle,
            theme: ThemeData(
                primarySwatch: Colors.red,
                primaryColor: Colors.red,
                accentColor: Colors.redAccent, // TODO replace accentColor property
                unselectedWidgetColor: Colors.grey,
                dividerColor: Colors.black54),
            initialRoute: Routes.initialRoute,
            routes: Routes.instance().getRoutes()));
  }
}
