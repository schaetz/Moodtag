import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/blocs/tags_list/tags_list_bloc.dart';
import 'package:moodtag/model/blocs/tags_list/tags_list_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/navigation/routes.dart';

class TagsListScreen extends StatelessWidget {
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  // TODO Define pale color in theme
  static const listEntryStylePale = TextStyle(fontSize: 18.0, color: Colors.grey);

  final GlobalKey<ScaffoldState> _scaffoldKey;

  TagsListScreen(this._scaffoldKey);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TagsListBloc>();
    return BlocBuilder<TagsListBloc, TagsListState>(
        buildWhen: (previous, current) => current.isTagsListLoaded, // TODO Show loading or error symbols
        builder: (context, state) {
          if (state.allTags == null || state.allTags!.isEmpty) {
            return const Align(
              alignment: Alignment.center,
              child: Text('No tags yet', style: listEntryStyle),
            );
          }

          return ListView.separated(
            separatorBuilder: (context, _) => Divider(),
            padding: EdgeInsets.all(16.0),
            itemCount: state.allTags!.isNotEmpty ? state.allTags!.length : 0,
            itemBuilder: (context, i) {
              return _buildTagRow(context, state.allTags![i], bloc);
            },
          );
        });
  }

  Widget _buildTagRow(BuildContext context, TagData tagData, TagsListBloc bloc) {
    final handleDeleteTag = () {
      bloc.add(DeleteTag(tagData.tag));
    };
    return ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Expanded(
              child: Text(
                tagData.tag.name,
                style: listEntryStyle,
              ),
            ),
            Text(
              tagData.freq.toString(),
              style: listEntryStylePale,
            )
          ],
        ),
        leading: Icon(Icons.label),
        onTap: () => Navigator.of(context).pushNamed(Routes.tagsDetails, arguments: tagData.tag.id),
        onLongPress: () => DeleteDialog.openNew<Tag>(_scaffoldKey.currentContext!,
            entityToDelete: tagData.tag, deleteHandler: handleDeleteTag));
  }
}
