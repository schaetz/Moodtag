import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/navigation.dart';

class ArtistsListScreen extends StatelessWidget {

  final NavigationItemChanged onBottomNavBarTapped;
  final ArtistChanged navigateToArtistDetails;

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  ArtistsListScreen({
    @required this.onBottomNavBarTapped,
    @required this.navigateToArtistDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(),
      body: Consumer<Library>(
        builder: (context, library, child) {
          return ListView.separated(
            separatorBuilder: (context, _) => Divider(),
            padding: EdgeInsets.all(16.0),
            itemCount: library.artists.length,
            itemBuilder: (context, i) {
              return _buildArtistRow(context, library.artists[i], navigateToArtistDetails);
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEntityDialog.openAddArtistDialog(context),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
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
      onLongPress: () => DeleteDialog.openNew<Artist>(context, artist)
    );
  }

}
