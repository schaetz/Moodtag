import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/main.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_artist_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';

class ArtistsListScreen extends StatelessWidget {

  final String title;
  final NavigationItemChanged onBottomNavBarTapped;
  final ArtistChanged navigateToArtistDetails;

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  ArtistsListScreen({
    this.title,
    @required this.onBottomNavBarTapped,
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
          return ListView.separated(
            separatorBuilder: (pro, context) => Divider(color: Colors.black),
            padding: EdgeInsets.all(16.0),
            itemCount: library.artists.length,
            itemBuilder: (context, i) {
              return _buildArtistRow(context, library.artists[i], navigateToArtistDetails);
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddArtistDialog(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.artists, onBottomNavBarTapped),
    );
  }

  Widget _buildArtistRow(BuildContext context, Artist artist, ArtistChanged onTapped) {
    return ListTile(
      title: Text(
        artist.name,
        style: listEntryStyle,
      ),
      onTap: () => navigateToArtistDetails(context, artist),
      onLongPress: () => showDeleteDialog(context, artist)
    );
  }

}
