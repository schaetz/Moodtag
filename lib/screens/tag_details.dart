import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/database/moodtag_db.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/remove_tag_from_artist_dialog.dart';
import 'package:moodtag/navigation/routes.dart';

class TagDetailsScreen extends StatelessWidget {

  final Tag tag;

  static const tagNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  TagDetailsScreen(BuildContext context) :
    tag = ModalRoute.of(context).settings.arguments as Tag;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);

    return Scaffold(
      appBar: MtAppBar(context),
      body: StreamBuilder<List<Artist>>(
        stream: bloc.artistsWithTag(tag),
        builder: (context, snapshot) {
          List<Artist> artistsWithTag = snapshot.hasData ? snapshot.data : [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      tag.name + ' (' + artistsWithTag.length.toString() + ')',
                      style: tagNameStyle
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (BuildContext context) {
                        if (artistsWithTag.isEmpty) {
                          return const Align(
                            alignment: Alignment.center,
                            child: Text('No artists with this tag', style: listEntryStyle),
                          );
                        }

                        return ListView.separated(
                          separatorBuilder: (context, _) => Divider(),
                          padding: EdgeInsets.all(16.0),
                          itemCount: artistsWithTag.length,
                          itemBuilder: (context, i) {
                            return _buildArtistRow(context, artistsWithTag[i]);
                          },
                        );
                      }
                    )
                  ),
                ]
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

  Widget _buildArtistRow(BuildContext context, Artist artist) {
    return ListTile(
      title: Text(
        artist.name,
        style: listEntryStyle,
      ),
      onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artist),
      onLongPress: () => RemoveTagFromArtistDialog.openNew(context, tag, artist)
    );
  }

}
