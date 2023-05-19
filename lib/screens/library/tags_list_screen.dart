import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/blocs/tags_list/tags_list_bloc.dart';
import 'package:moodtag/model/blocs/tags_list/tags_list_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/navigation/navigation_item.dart';
import 'package:moodtag/navigation/routes.dart';

class TagsListScreen extends StatelessWidget {
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  // TODO Define pale color in theme
  static const listEntryStylePale = TextStyle(fontSize: 18.0, color: Colors.grey);

  final GlobalKey _scaffoldKey = GlobalKey();

  TagsListScreen();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TagsListBloc>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: MtAppBar(context),
      body: BlocBuilder<TagsListBloc, TagsListState>(
          buildWhen: (previous, current) => current.loadingStatus.isSuccess, // TODO Show loading or error symbols
          builder: (context, state) {
            if (state.tags.isEmpty) {
              return const Align(
                alignment: Alignment.center,
                child: Text('No tags yet', style: listEntryStyle),
              );
            }

            return ListView.separated(
              separatorBuilder: (context, _) => Divider(),
              padding: EdgeInsets.all(16.0),
              itemCount: state.tags.isNotEmpty ? state.tags.length : 0,
              itemBuilder: (context, i) {
                return _buildTagRow(context, state.tags[i], state.artistFrequencies[i], bloc);
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddEntityDialog.openAddTagDialog(context, onSendInput: (input) => bloc.add(CreateTags(input))),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.tags),
    );
  }

  Widget _buildTagRow(BuildContext context, Tag tag, TagData artistFreq, TagsListBloc bloc) {
    final handleDeleteTag = () {
      bloc.add(DeleteTag(tag));
    };
    return ListTile(
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
              artistFreq.freq.toString(),
              style: listEntryStylePale,
            )
          ],
        ),
        leading: Icon(Icons.label),
        onTap: () => Navigator.of(context).pushNamed(Routes.tagsDetails, arguments: tag.id),
        onLongPress: () => DeleteDialog.openNew<Tag>(_scaffoldKey.currentContext!,
            entityToDelete: tag, deleteHandler: handleDeleteTag));
  }
}
