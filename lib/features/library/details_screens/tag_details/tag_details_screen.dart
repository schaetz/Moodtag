import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_bloc.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_screen_bottom_app_bar.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/dialogs/add_entity_dialog.dart';
import 'package:moodtag/shared/dialogs/remove_tag_from_artist_dialog.dart';
import 'package:moodtag/shared/dialogs/select_entity/select_entity_dialog.dart';
import 'package:moodtag/shared/dialogs/select_entity/select_entity_dialog_config.dart';
import 'package:moodtag/shared/widgets/data_display/loaded_data_display_wrapper.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_main_scaffold.dart';
import 'package:moodtag/shared/widgets/screen_extensions/searchable_list_screen_mixin.dart';
import 'package:moodtag/shared/widgets/text_input/search_bar_container.dart';

class TagDetailsScreen extends StatelessWidget with SearchableListScreenMixin<TagDetailsBloc> {
  static const tagNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey listViewKey = GlobalKey();

  TagDetailsScreen();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TagDetailsBloc>();
    return MtMainScaffold(
      scaffoldKey: _scaffoldKey,
      pageWidget: BlocBuilder<TagDetailsBloc, TagDetailsState>(
        builder: (context, state) {
          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LoadedDataDisplayWrapper<TagData>(
                  loadedData: state.loadedTagData,
                  captionForError: 'Tag could not be loaded',
                  captionForEmptyData: 'Tag does not exist',
                  buildOnSuccess: (tagData) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: _buildHeadline(context, state),
                        ),
                        _buildChipsRow(context, state, bloc),
                        Expanded(
                            child: SearchBarContainer(
                          searchBarHintText: 'Search artist',
                          searchBarVisible: state.displaySearchBar,
                          onSearchBarTextChanged: (value) => onSearchBarTextChanged(value, bloc),
                          onSearchBarClosed: () => onSearchBarClosed(bloc),
                          contentWidget: LoadedDataDisplayWrapper<ArtistsList>(
                            loadedData: state.checklistMode
                                ? state.loadedDataFilteredArtists
                                : state.loadedDataFilteredArtistsWithTag,
                            captionForError: 'Artists with this tag could not be loaded',
                            captionForEmptyData: 'No artists with this tag',
                            additionalCheckData: state.checklistMode
                                ? state.loadedDataFilteredArtistsWithTag
                                : state.loadedDataFilteredArtists,
                            buildOnSuccess: (artistsWithThisTagOnly) => ListView.separated(
                              separatorBuilder: (context, _) => Divider(),
                              padding: EdgeInsets.all(4.0),
                              itemCount: state.checklistMode
                                  ? state.loadedDataFilteredArtists.data!.length
                                  : state.loadedDataFilteredArtistsWithTag.data!.length,
                              itemBuilder: (context, i) {
                                return state.checklistMode
                                    ? _buildRowForArtistSelection(
                                        context, tagData.tag, state.loadedDataFilteredArtists.data![i], bloc)
                                    : _buildRowForAssociatedArtist(context, tagData.tag,
                                        state.loadedDataFilteredArtistsWithTag.data![i].artist, bloc);
                              },
                            ),
                          ),
                          listViewKey: listViewKey,
                        )),
                      ])));
        },
      ),
      bottomNavigationBar: TagDetailsScreenBottomAppBar(),
      floatingActionButton: BlocBuilder<TagDetailsBloc, TagDetailsState>(builder: (context, state) {
        return LoadedDataDisplayWrapper<TagData>(
            loadedData: state.loadedTagData,
            additionalCheckData: state.allArtists,
            showPlaceholders: false,
            buildOnSuccess: (tagData) => FloatingActionButton(
                onPressed: () => AddEntityDialog.openAddArtistDialog(context,
                    preselectedTag: tagData.tag,
                    onSendInput: (input) => bloc.add(AddArtistsForTag(input, tagData.tag)),
                    suggestedEntities: state.allArtists.data),
                child: const Icon(Icons.library_add)));
      }),
    );
  }

  Widget _buildHeadline(BuildContext context, TagDetailsState state) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Icon(Icons.label),
          ),
          WidgetSpan(
            child: SizedBox(width: 4),
          ),
          TextSpan(
              text: state.loadedTagData.data?.name ?? 'Unknown tag',
              style: tagNameStyle.copyWith(color: Theme.of(context).colorScheme.onBackground)),
        ],
      ),
    );
  }

  Widget _buildChipsRow(BuildContext context, TagDetailsState state, TagDetailsBloc bloc) {
    if (state.loadedTagData.data == null) {
      return Container();
    }
    final tag = state.loadedTagData.data!.tag;
    final category = state.loadedTagData.data!.category;
    final categoryData = state.allTagCategories.data?.firstWhere((data) => data.tagCategory.id == category.id);
    return Row(
      children: [
        ActionChip(
            label: Text(category.name),
            avatar: Icon(Icons.category, color: Colors.black),
            backgroundColor: Color(category.color),
            onPressed: state.allTagCategories.data == null
                ? null
                : () => SelectEntityDialog<TagCategoryData>(
                      context,
                      SelectEntityDialogConfig(
                          title: 'Select the tag category for "${state.loadedTagData.data?.name}"',
                          availableEntities: state.allTagCategories.data!,
                          initialSelection: categoryData,
                          onSendInput: (newCategoryData) =>
                              bloc.add(ChangeCategoryForTag(tag, newCategoryData.tagCategory)),
                          selectionStyle: EntityDialogSelectionStyle.ONE_TAP,
                          iconSelector: (categoryData) =>
                              Icon(Icons.circle, color: Color(categoryData.tagCategory.color))),
                    ))
      ],
    );
  }

  Widget _buildRowForArtistSelection(BuildContext context, Tag tag, ArtistData artistData, TagDetailsBloc bloc) {
    return CheckboxListTile(
      title: Text(
        artistData.artist.name,
        style: listEntryStyle,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.only(right: 4.0),
      value: artistData.hasTag(tag),
      onChanged: (bool? value) => bloc.add(ToggleTagForArtist(artistData.artist, tag)),
    );
  }

  Widget _buildRowForAssociatedArtist(BuildContext context, Tag tag, Artist artist, TagDetailsBloc bloc) {
    final handleRemoveTagFromArtist = () {
      bloc.add(RemoveTagFromArtist(artist, tag));
    };
    return ListTile(
        title: Text(
          artist.name,
          style: listEntryStyle,
        ),
        onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artist.id),
        onLongPress: () =>
            RemoveTagFromArtistDialog.openNew(_scaffoldKey.currentContext!, tag, artist, handleRemoveTagFromArtist));
  }
}
