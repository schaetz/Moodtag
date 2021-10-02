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
import 'package:moodtag/navigation.dart';
import 'package:moodtag/screens/artist_details.dart';
import 'package:moodtag/screens/artists_list.dart';
import 'package:moodtag/screens/tag_details.dart';
import 'package:moodtag/screens/tags_list.dart';

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
  static const initialRoute = '/artists';

  Artist _selectedArtist;
  Tag _selectedTag;
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
        initialRoute: initialRoute,
        routes: {
          '/artists': (context) => ArtistsListScreen(
            onBottomNavBarTapped: _handleBottomNavBarTapped,
            navigateToArtistDetails: _navigateToArtistDetails,
          ),
          '/tags': (context) => TagsListScreen(
            onBottomNavBarTapped: _handleBottomNavBarTapped,
            navigateToTagDetails: _navigateToTagDetails,
          ),
          '/artists/details': (context) => ArtistDetailsScreen(
            artist: _selectedArtist,
            navigateToTagDetails: _navigateToTagDetails,
          ),
          '/tags/details': (context) => TagDetailsScreen(
            tag: _selectedTag,
            navigateToArtistDetails: _navigateToArtistDetails,
          ),
        },
      )
    );
  }

  void _handleBottomNavBarTapped(BuildContext context, NavigationItem navigationItem) {
    switch (navigationItem) {
      case NavigationItem.artists:
        Navigator.of(context).pushReplacementNamed('/artists');
        break;
      case NavigationItem.tags:
        Navigator.of(context).pushReplacementNamed('/tags');
        break;
    }
  }

  void _navigateToArtistDetails(BuildContext context, Artist artist) {
    _selectedArtist = artist;
    _selectedTag = null;

    Navigator.of(context).pushNamed('/artists/details');
  }

  void _navigateToTagDetails(BuildContext context, Tag tag) {
    _selectedTag = tag;
    _selectedArtist = null;

    Navigator.of(context).pushNamed('/tags/details');
  }

}
