import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/main.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class TagDetailsPage extends Page {
  final String title;
  final Tag tag;
  final ArtistChanged onArtistTapped;

  TagDetailsPage({
    this.title,
    @required this.tag,
    @required this.onArtistTapped
  }) : super(key: ValueKey(tag));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return TagDetailsScreen(
              title: title,
              tag: tag,
              onArtistTapped: onArtistTapped
          );
        });
  }
}

class TagDetailsScreen extends StatelessWidget {
  final String title;
  final Tag tag;
  final ArtistChanged onArtistTapped;

  static const tagNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  const TagDetailsScreen({
    @required this.title,
    @required this.tag,
    @required this.onArtistTapped,
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
                  child: Text(tag.name + ' (' + library.getArtistsWithTag(tag).length.toString() + ')', style: tagNameStyle),
                ),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (pro, context) => Divider(color: Colors.black),
                    padding: EdgeInsets.all(16.0),
                    itemCount: library.getArtistsWithTag(tag).length,
                    itemBuilder: (context, i) {
                      return _buildArtistRow(context, library.getArtistsWithTag(tag)[i], onArtistTapped);
                    },
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildArtistRow(BuildContext context, Artist artist, ArtistChanged onTapped) {
    return ListTile(
      title: Text(
        artist.name,
        style: listEntryStyle,
      ),
      onTap: () => onArtistTapped(context, artist),
    );
  }

}
