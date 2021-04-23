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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodtag',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ArtistsList(title: 'Moodtag'),
    );
  }
}

class ArtistsList extends StatefulWidget {
  ArtistsList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ArtistsListState createState() => _ArtistsListState();
}

class _ArtistsListState extends State<ArtistsList> {
  final _artists = <String>[
    'AC/DC',
    'The Beatles',
    'Deep Purple',
    'The Rolling Stones'
  ];
  final _biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildArtistsList(),
    );
  }

  Widget _buildArtistsList() {
    return ListView.separated(
        separatorBuilder: (pro, context) => Divider(color: Colors.black),
        padding: EdgeInsets.all(16.0),
        itemCount: _artists.length,
        itemBuilder: (context, i) {
          return _buildArtistRow(_artists[i]);
        });
  }

  Widget _buildArtistRow(String artistName) {
    return ListTile(
      title: Text(
        artistName,
        style: _biggerFont,
      ),
    );
  }
}
