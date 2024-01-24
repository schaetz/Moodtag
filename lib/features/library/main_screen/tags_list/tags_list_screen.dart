import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/library/main_screen/tags_list/tags_list_bloc.dart';
import 'package:moodtag/features/library/main_screen/tags_list/tags_list_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog.dart';
import 'package:moodtag/shared/widgets/data_display/loaded_data_display_wrapper.dart';
import 'package:moodtag/shared/widgets/screen_extensions/searchable_list_screen_mixin.dart';
import 'package:moodtag/shared/widgets/text_input/search_bar_container.dart';

class TagsListScreen extends StatelessWidget with SearchableListScreenMixin<TagsListBloc> {
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  // TODO Define pale color in theme
  static const listEntryStylePale = TextStyle(fontSize: 18.0, color: Colors.grey);

  final GlobalKey listViewKey = GlobalKey();

  final GlobalKey<ScaffoldState> _scaffoldKey;

  TagsListScreen(this._scaffoldKey);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TagsListBloc>();
    return BlocBuilder<TagsListBloc, TagsListState>(builder: (context, state) {
      return SearchBarContainer(
          listViewKey: listViewKey,
          searchBarHintText: 'Search tag',
          searchBarVisible: state.displaySearchBar,
          onSearchBarTextChanged: (value) => onSearchBarTextChanged(value, bloc),
          onSearchBarClosed: () => onSearchBarClosed(bloc),
          contentWidget: LoadedDataDisplayWrapper<TagsList>(
              loadedData: state.loadedDataFilteredTags,
              captionForError: 'Tags could not be loaded',
              captionForEmptyData: !state.displaySearchBar || state.searchItem.isEmpty
                  ? 'No tags yet'
                  : 'No tags match the selected filters',
              buildOnSuccess: (filteredTagsList) => ListView.separated(
                    separatorBuilder: (context, _) => Divider(),
                    padding: EdgeInsets.all(16.0),
                    itemCount: filteredTagsList.isNotEmpty ? filteredTagsList.length : 0,
                    itemBuilder: (context, i) {
                      return _buildTagRow(context, filteredTagsList[i], bloc);
                    },
                  )));
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
        onLongPress: () => DeleteEntityDialog.construct<Tag>(_scaffoldKey.currentContext!,
            options: [], // TODO Define options
            entityToDelete: tagData.tag,
            deleteHandler: handleDeleteTag)
          ..show());
  }
}
