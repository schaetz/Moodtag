import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';

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

  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

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
      body: Consumer<Library>(
        builder: (context, library, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(artist.name, style: artistNameStyle),
                ),
                Wrap(
                  spacing: 1.0,
                  runSpacing: 2.0,
                  children: [
                    Chip(label: Text('Rock')),
                    SizedBox(width: 8),
                    Chip(label: Text('70s')),
                  ],
                )
              ]
            ),
          );
        }
      ),
    );
  }
}
