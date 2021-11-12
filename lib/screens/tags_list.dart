import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/database/moodtag_db.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/navigation/navigation_item.dart';
import 'package:moodtag/navigation/routes.dart';

class TagsListScreen extends StatelessWidget {

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);

    return Scaffold(
      appBar: MtAppBar(context),
      body: StreamBuilder<List<Tag>>(
        stream: bloc.tags,
        builder: (context, snapshot) {
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
              return _buildTagRow(context, snapshot.data[i]);
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEntityDialog.openAddTagDialog(context),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.tags),
    );
  }

  Widget _buildTagRow(BuildContext context, Tag tag) {
    return ListTile(
      title: Text(
        tag.name,
        style: listEntryStyle,
      ),
      onTap: () => Navigator.of(context).pushNamed(Routes.tagsDetails, arguments: tag),
      onLongPress: () => DeleteDialog.openNew<Tag>(context, tag)
    );
  }

}
