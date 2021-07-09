import 'package:flutter/material.dart';

import 'package:moodtag/models/artist.dart';

class ArtistDetailsPage extends Page {
  final String title;
  final Artist artist;

  ArtistDetailsPage({this.title, this.artist}) : super(key: ValueKey(artist));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return ArtistDetailsScreen(title: title, artist: artist);
        });
  }
}

class ArtistDetailsScreen extends StatelessWidget {
  final String title;
  final Artist artist;

  ArtistDetailsScreen({
    @required this.title,
    @required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Chip(label: Text('Rock')),
              SizedBox(width: 8),
              Chip(label: Text('70s')),
            ],
          )),
    );
  }
}
