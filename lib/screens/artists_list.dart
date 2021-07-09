import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';

class ArtistsListScreen extends StatelessWidget {

  final String title;
  final ValueChanged<Artist> onTapped;

  final _biggerFont = TextStyle(fontSize: 18.0);

  ArtistsListScreen(
      {this.title, @required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Consumer<Library>(
        builder: (context, library, child) {
          return ListView.separated(
            separatorBuilder: (pro, context) => Divider(color: Colors.black),
            padding: EdgeInsets.all(16.0),
            itemCount: library.artists.length,
            itemBuilder: (context, i) {
              return _buildArtistRow(library.artists[i], onTapped);
            },
          );
        }
      ),
    );
  }

  Widget _buildArtistRow(Artist artist, ValueChanged<Artist> onTapped) {
    return ListTile(
      title: Text(
        artist.name,
        style: _biggerFont,
      ),
      onTap: () => onTapped(artist),
    );
  }
}
