import 'package:flutter/material.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/database/moodtag_db.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/navigation/navigation_item.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:provider/provider.dart';

class TagsListScreen extends StatelessWidget {
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  // TODO Define pale color in theme
  static const listEntryStylePale = TextStyle(fontSize: 18.0, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);

    return Scaffold(
      appBar: MtAppBar(context),
      body: StreamBuilder<List<Tag>>(
          stream: bloc.tags,
          builder: (context, snapshot) {
            print(snapshot);

            if (!snapshot.hasData) {
              return const Align(
                alignment: Alignment.center,
                child: Text('No tags yet', style: listEntryStyle),
              );
            }

            return ListView.separated(
              separatorBuilder: (context, _) => Divider(),
              padding: EdgeInsets.all(16.0),
              itemCount: snapshot.hasData ? snapshot.data.length : 0,
              itemBuilder: (context, i) {
                return _buildTagRow(context, bloc, snapshot.data[i]);
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEntityDialog.openAddTagDialog(context),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.tags),
    );
  }

  Widget _buildTagRow(BuildContext context, MoodtagBloc bloc, Tag tag) {
    return StreamBuilder<List<Artist>>(
        stream: bloc.artistsWithTag(tag),
        builder: (context, artistsWithTagSnapshot) => ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Expanded(
                  child: Text(
                    tag.name,
                    style: listEntryStyle,
                  ),
                ),
                Text(
                  artistsWithTagSnapshot.hasData ? artistsWithTagSnapshot.data.length.toString() : "0",
                  style: listEntryStylePale,
                )
              ],
            ),
            leading: Icon(Icons.label),
            onTap: () => Navigator.of(context).pushNamed(Routes.tagsDetails, arguments: tag),
            onLongPress: () => DeleteDialog.openNew<Tag>(context, entityToDelete: tag)));
  }
}
