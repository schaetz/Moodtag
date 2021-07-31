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
import 'package:moodtag/screens/tag_details.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

import 'package:moodtag/screens/artist_details.dart';
import 'package:moodtag/screens/artists_list.dart';
import 'package:moodtag/screens/tags_list.dart';

void main() {
  runApp(MoodtagApp(title: 'Moodtag'));
}

class MoodtagApp extends StatefulWidget {
  MoodtagApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppState createState() => _AppState();
}

enum NavigationItem {
  artists, tags
}

typedef ArtistChanged = void Function(BuildContext context, Artist artist);
typedef TagChanged = void Function(BuildContext context, Tag artist);

class _AppState extends State<MoodtagApp> {

  static const appTitle = 'Moodtag';
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

  Artist _selectedArtist;
  Tag _selectedTag;
  bool _showTagsList = false;
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
        title: appTitle,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        initialRoute: '/artists',
        routes: {
          '/artists': (context) => ArtistsListScreen(
            title: appTitle,
            onBottomNavBarTapped: _handleBottomNavBarTapped,
            onArtistTapped: _handleArtistTapped,
          ),
          '/tags': (context) => TagsListScreen(
            title: appTitle,
            onBottomNavBarTapped: _handleBottomNavBarTapped,
            onTagTapped: _handleTagTapped,
          ),
          '/artists/details': (context) => ArtistDetailsScreen(
            title: appTitle,
            artist: _selectedArtist,
            onTagTapped: _handleTagTapped,
          ),
          '/tags/details': (context) => TagDetailsScreen(
            title: appTitle,
            tag: _selectedTag,
            onArtistTapped: _handleArtistTapped,
          ),
        },
      )
    );
  }

  void _handleBottomNavBarTapped(NavigationItem navigationItem) {
    switch (navigationItem) {
      case NavigationItem.artists:
        _showTagsList = false;
        break;
      case NavigationItem.tags:
        _showTagsList = true;
        break;
    }
    print('Show tags list: ' + _showTagsList.toString());
  }

  void _handleArtistTapped(BuildContext context, Artist artist) {
    _selectedArtist = artist;
    //_selectedTag = null;
    print('Tapped artist: ' + artist.name);

    Navigator.of(context).pushNamed('/artists/details');
  }

  void _handleTagTapped(BuildContext context, Tag tag) {
    _selectedTag = tag;
    //_selectedArtist = null;
    print('Tapped tag: ' + tag.name);

    Navigator.of(context).pushNamed('/tags/details');
  }

}
