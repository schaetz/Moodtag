import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';
import 'package:moodtag/navigation.dart';

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
              tag: tag,
              navigateToArtistDetails: navigateToArtistDetails
          );
        });
  }
}

class TagDetailsScreen extends StatelessWidget {

  final Tag tag;
  final ArtistChanged navigateToArtistDetails;

  static const tagNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  const TagDetailsScreen({
    @required this.tag,
    @required this.navigateToArtistDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(),
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
                    separatorBuilder: (context, _) => Divider(),
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
        onPressed: () => AddEntityDialog.openAddArtistDialog(context, preselectedTag: tag),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
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
