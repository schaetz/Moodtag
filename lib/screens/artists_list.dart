import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';

class ArtistsListScreen extends StatelessWidget {

  final String title;
  final ValueChanged<Artist> onArtistTapped;

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  ArtistsListScreen(
      {this.title, @required this.onArtistTapped});

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
              return _buildArtistRow(library.artists[i], onArtistTapped);
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
        style: listEntryStyle,
      ),
      onTap: () => onArtistTapped(artist),
    );
  }

}
