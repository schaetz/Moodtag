import 'package:flutter/material.dart';

class ArtistsListScreen extends StatelessWidget {
  final String title;
  final List<String> artists;
  final ValueChanged<String> onTapped;

  final _biggerFont = TextStyle(fontSize: 18.0);

  ArtistsListScreen(
      {this.title, @required this.artists, @required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.separated(
        separatorBuilder: (pro, context) => Divider(color: Colors.black),
        padding: EdgeInsets.all(16.0),
        itemCount: artists.length,
        itemBuilder: (context, i) {
          return _buildArtistRow(artists[i], onTapped);
        },
      ),
    );
  }

  Widget _buildArtistRow(String artist, ValueChanged<String> onTapped) {
    return ListTile(
      title: Text(
        artist,
        style: _biggerFont,
      ),
      onTap: () => onTapped(artist),
    );
  }
}
