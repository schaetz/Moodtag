import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_bloc.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_screen_bottom_app_bar.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_state.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/dialogs/alert_dialog_factory.dart';
import 'package:moodtag/shared/dialogs/form/fields/entity_selection/entity_selection_dialog_form_field.dart';
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
    final dialogFactory = context.read<AlertDialogFactory>();

    return MtMainScaffold(
      scaffoldKey: _scaffoldKey,
      pageWidget: BlocBuilder<TagDetailsBloc, TagDetailsState>(
        builder: (context, state) {
          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LoadedDataDisplayWrapper<Tag>(
                  loadedData: state.loadedTagData,
                  captionForError: 'Tag could not be loaded',
                  captionForEmptyData: 'Tag does not exist',
                  buildOnSuccess: (tag) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: _buildHeadline(context, state),
                        ),
                        _buildChipsRow(context, state, bloc, dialogFactory),
                        Expanded(
                            child: SearchBarContainer(
                          searchBarHintText: 'Search artist',
                          searchBarVisible: state.displaySearchBar,
                          onSearchBarTextChanged: (value) => onSearchBarTextChanged(value, bloc),
                          onSearchBarClosed: () => onSearchBarClosed(bloc),
                          contentWidget: LoadedDataDisplayWrapper<List<Artist>>(
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
                                        context, tag, state.loadedDataFilteredArtists.data![i], bloc)
                                    : _buildRowForAssociatedArtist(context, tag,
                                        state.loadedDataFilteredArtistsWithTag.data![i], bloc, dialogFactory);
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
        return LoadedDataDisplayWrapper<Tag>(
            loadedData: state.loadedTagData,
            additionalCheckData: state.allArtists,
            showPlaceholders: false,
            buildOnSuccess: (tag) => FloatingActionButton(
                onPressed: () => dialogFactory
                    .getSingleTextInputDialog(context,
                        title: 'Add artists for tag',
                        subtitle: 'Separate multiple artists by line breaks',
                        multiline: true,
                        maxLines: 10,
                        suggestedEntities: state.allArtists.data?.toSet())
                    .show(onTruthyResult: (input) => bloc.add(AddArtistsForTag(input!, tag))),
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

  Widget _buildChipsRow(
      BuildContext context, TagDetailsState state, TagDetailsBloc bloc, AlertDialogFactory dialogFactory) {
    if (state.loadedTagData.data == null) {
      return Container();
    }
    final tag = state.loadedTagData.data!;
    final category = state.loadedTagData.data!.category;
    final categoryData = state.allTagCategories.data?.firstWhere((tagCategory) => tagCategory.id == category.id);
    return Row(
      children: [
        ActionChip(
            label: Text(category.name),
            avatar: Icon(Icons.category, color: Colors.black),
            backgroundColor: Color(category.color),
            onPressed: state.allTagCategories.data == null || categoryData == null
                ? null
                : () => dialogFactory
                    .getSelectEntityDialog<TagCategory>(context,
                        title: 'Select the tag category for "${state.loadedTagData.data?.name}"',
                        entities: state.allTagCategories.data!,
                        initialSelection: categoryData,
                        selectionStyle: EntityDialogSelectionStyle.ONE_TAP,
                        iconSelector: (selectableCategory) =>
                            Icon(Icons.circle, color: Color(selectableCategory.color)))
                    .show(onTruthyResult: (newTagCategory) => bloc.add(ChangeCategoryForTag(tag, newTagCategory))))
      ],
    );
  }

  Widget _buildRowForArtistSelection(BuildContext context, Tag tag, Artist artist, TagDetailsBloc bloc) {
    return CheckboxListTile(
      title: Text(
        artist.name,
        style: listEntryStyle,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.only(right: 4.0),
      value: artist.hasTag(tag),
      onChanged: (bool? value) => bloc.add(ToggleTagForArtist(artist, tag)),
    );
  }

  Widget _buildRowForAssociatedArtist(
      BuildContext context, Tag tag, Artist artist, TagDetailsBloc bloc, AlertDialogFactory dialogFactory) {
    return ListTile(
        title: Text(
          artist.name,
          style: listEntryStyle,
        ),
        onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artist.id),
        onLongPress: () => dialogFactory
            .getConfirmationDialog(_scaffoldKey.currentContext!,
                title: 'Remove the tag "${tag.name}" from the artist "${artist.name}"?')
            .show(onTruthyResult: (_) => bloc.add(RemoveTagFromArtist(artist, tag))));
  }
}
