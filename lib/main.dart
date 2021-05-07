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
import 'package:moodtag/artist_details.dart';
import 'package:moodtag/artists_list.dart';

void main() {
  runApp(MoodtagApp(title: 'Moodtag'));
}

class MoodtagApp extends StatefulWidget {
  MoodtagApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MoodtagApp> {
  final _artists = <String>[
    'AC/DC',
    'The Beatles',
    'Deep Purple',
    'The Rolling Stones'
  ];
  String _selectedArtist;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodtag',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Navigator(
        pages: [
          MaterialPage(
            key: ValueKey('ArtistsListPage'),
            child: ArtistsListScreen(
              title: 'Moodtag',
              artists: _artists,
              onTapped: _handleArtistTapped,
            ),
          ),
          if (_selectedArtist != null)
            ArtistDetailsPage(
              title: 'Moodtag',
              artist: _selectedArtist,
            )
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          // Update the list of pages by setting _selectedArtist to null
          setState(() {
            _selectedArtist = null;
          });

          return true;
        },
      ),
    );
  }

  void _handleArtistTapped(String artist) {
    setState(() {
      _selectedArtist = artist;
    });
  }
}
