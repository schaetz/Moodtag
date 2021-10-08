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
import 'package:provider/provider.dart';

import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';
import 'package:moodtag/navigation/routes.dart';

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

  static const _sampleArtistNames = <String>[
    'AC/DC',
    'The Beatles',
    'Deep Purple',
    'The Rolling Stones'
  ];
  static const _sampleTagNames = <String>[
    '80s',
    'Rock',
    'Mellow',
    'Cheerful'
  ];

  final sampleTags;
  final sampleArtists;

  _AppState._(this.sampleTags, this.sampleArtists);

  factory _AppState() {
      var sampleTags = _sampleTagNames.map((name) => Tag(name)).toList();
      var sampleArtists = _sampleArtistNames.map((name) => Artist.withTags(name, sampleTags)).toList();

      return new _AppState._(sampleTags, sampleArtists);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Library(this.sampleArtists, this.sampleTags),
      child: MaterialApp(
        title: MoodtagApp.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Colors.red,
          accentColor: Colors.redAccent,
          unselectedWidgetColor: Colors.grey,
          dividerColor: Colors.black54
        ),
        initialRoute: Routes.initialRoute,
        routes: Routes.instance().getRoutes()
      )
    );
  }

}
