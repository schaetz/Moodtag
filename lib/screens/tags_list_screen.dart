import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/blocs/tags_list/tags_list_bloc.dart';
import 'package:moodtag/model/blocs/tags_list/tags_list_state.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/navigation/navigation_item.dart';
import 'package:moodtag/navigation/routes.dart';

class TagsListScreen extends StatelessWidget {
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  // TODO Define pale color in theme
  static const listEntryStylePale = TextStyle(fontSize: 18.0, color: Colors.grey);

  TagsListScreen();

  AddEntityDialog<Tag, Artist>? _createTagDialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context),
      body: BlocConsumer<TagsListBloc, TagsListState>(
          listener: (context, state) {
            if (state.showCreateTagDialog) {
              _createTagDialog = AddEntityDialog.openAddTagDialog(context,
                  onSendInput: (input) => context.read<TagsListBloc>().add(CreateTags(input)),
                  onTerminate: (_) => context.read<TagsListBloc>().add(CloseCreateTagDialog()));
            } else if (_createTagDialog != null) {
              _createTagDialog!.closeDialog(context);
              _createTagDialog = null;
            }
          },
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
                return _buildTagRow(context, state.tags[i]);
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<TagsListBloc>().add(OpenCreateTagDialog()),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.tags),
    );
  }

  Widget _buildTagRow(BuildContext context, Tag tag) {
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
              "0", // TODO Display correct number of artists with tag
              style: listEntryStylePale,
            )
          ],
        ),
        leading: Icon(Icons.label),
        onTap: () => Navigator.of(context).pushNamed(Routes.tagsDetails, arguments: tag.id),
        onLongPress: () => DeleteDialog.openNew<Tag>(context, entityToDelete: tag));
  }
}
