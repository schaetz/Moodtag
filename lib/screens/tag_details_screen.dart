import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/remove_tag_from_artist_dialog.dart';
import 'package:moodtag/model/bloc/tags/tags_bloc.dart';
import 'package:moodtag/model/bloc/tags/tags_state.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/navigation/routes.dart';

class TagDetailsScreen extends StatelessWidget {
  final Tag tag;

  static const tagNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  TagDetailsScreen(BuildContext context) : tag = ModalRoute.of(context).settings.arguments as Tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context),
      body: BlocBuilder<TagsBloc, TagsState>(
        buildWhen: (previous, current) => current.status.isSuccess,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child:
                    Text(tag.name + ' (' + state.artistsWithSelectedTag.length.toString() + ')', style: tagNameStyle),
              ),
              Expanded(child: Builder(builder: (BuildContext context) {
                if (state.artistsWithSelectedTag.isEmpty) {
                  return const Align(
                    alignment: Alignment.center,
                    child: Text('No artists with this tag', style: listEntryStyle),
                  );
                }

                return ListView.separated(
                  separatorBuilder: (context, _) => Divider(),
                  padding: EdgeInsets.all(16.0),
                  itemCount: state.artistsWithSelectedTag.length,
                  itemBuilder: (context, i) {
                    return _buildArtistRow(context, state.artistsWithSelectedTag[i]);
                  },
                );
              })),
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEntityDialog.openAddArtistDialog(context, preselectedTag: tag),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
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
        onLongPress: () => RemoveTagFromArtistDialog.openNew(context, tag, artist));
  }
}
