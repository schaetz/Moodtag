import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/dialogs/add_artist_dialog.dart';
import 'package:moodtag/main.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class TagDetailsPage extends Page {
  final String title;
  final Tag tag;
  final ArtistChanged navigateToArtistDetails;

  TagDetailsPage({
    this.title,
    @required this.tag,
    @required this.navigateToArtistDetails
  }) : super(key: ValueKey(tag));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return TagDetailsScreen(
              title: title,
              tag: tag,
              navigateToArtistDetails: navigateToArtistDetails
          );
        });
  }
}

class TagDetailsScreen extends StatelessWidget {
  final String title;
  final Tag tag;
  final ArtistChanged navigateToArtistDetails;

  static const tagNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  const TagDetailsScreen({
    @required this.title,
    @required this.tag,
    @required this.navigateToArtistDetails,
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
                      return _buildArtistRow(context, library.getArtistsWithTag(tag)[i], navigateToArtistDetails);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddArtistDialog(context, tag);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildArtistRow(BuildContext context, Artist artist, ArtistChanged onTapped) {
    return ListTile(
      title: Text(
        artist.name,
        style: listEntryStyle,
      ),
      onTap: () => navigateToArtistDetails(context, artist),
    );
  }

}
