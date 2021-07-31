import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/main.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class ArtistDetailsPage extends Page {
  final String title;
  final Artist artist;
  final TagChanged onTagTapped;

  ArtistDetailsPage({
    this.title,
    @required this.artist,
    @required this.onTagTapped
  }) : super(key: ValueKey(artist));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return ArtistDetailsScreen(
              title: title,
              artist: artist,
              onTagTapped: onTagTapped,
          );
        });
  }
}

class ArtistDetailsScreen extends StatelessWidget {
  final String title;
  final Artist artist;
  final TagChanged onTagTapped;

  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  const ArtistDetailsScreen({
    @required this.title,
    @required this.artist,
    @required this.onTagTapped,
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
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _buildTagChipsRow(context, artist.tags),
                )
              ]
            ),
          );
        }
      ),
    );
  }

  List<Widget> _buildTagChipsRow(BuildContext context, List<Tag> tags) {
    return tags.map((tag) =>
      _buildTagChip(context, tag, (value) { })
    ).toList();
  }

  Widget _buildTagChip(BuildContext context, Tag tag, ValueChanged<Tag> onTapped) {
    return GestureDetector(
      onTap: () => onTagTapped(context, tag),
      child: Chip(
          label: Text(tag.name),
      ),
    );
  }

}
