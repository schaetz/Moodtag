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
import 'package:moodtag/screens/artist_details.dart';
import 'package:moodtag/screens/artists_list.dart';

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

  final _sampleArtistNames = <String>[
    'AC/DC',
    'The Beatles',
    'Deep Purple',
    'The Rolling Stones'
  ];
  Artist _selectedArtist;

  List<Artist> createSampleArtists() {
    return _sampleArtistNames.map((name) => Artist(name)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Library(createSampleArtists()),
      child: MaterialApp(
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
      )
    );
  }

  void _handleArtistTapped(Artist artist) {
    setState(() {
      _selectedArtist = artist;
    });
  }
}
