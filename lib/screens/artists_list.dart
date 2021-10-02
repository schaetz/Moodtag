import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/navigation_item.dart';
import 'package:moodtag/routes.dart';

class ArtistsListScreen extends StatelessWidget {

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context),
      body: Consumer<Library>(
        builder: (context, library, child) {
          return ListView.separated(
            separatorBuilder: (context, _) => Divider(),
            padding: EdgeInsets.all(16.0),
            itemCount: library.artists.length,
            itemBuilder: (context, i) {
              return _buildArtistRow(context, library.artists[i]);
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEntityDialog.openAddArtistDialog(context),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.artists),
    );
  }

  Widget _buildArtistRow(BuildContext context, Artist artist) {
    return ListTile(
      title: Text(
        artist.name,
        style: listEntryStyle,
      ),
      onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artist),
      onLongPress: () => DeleteDialog.openNew<Artist>(context, artist)
    );
  }

}
