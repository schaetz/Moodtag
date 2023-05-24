import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moodtag/components/filter_selector_overlay.dart';
import 'package:moodtag/components/loaded_data_display_wrapper.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/navigation/navigation_item.dart';
import 'package:moodtag/navigation/routes.dart';

class ArtistsListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ArtistsListScreenState();
}

class _ArtistsListScreenState extends State<ArtistsListScreen> {
  // static const errorLabelStyle = TextStyle(fontSize: 18.0, color: Colors.black);
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  static const tagChipLabelStyle = TextStyle(fontSize: 10.0, color: Colors.black87);

  final GlobalKey _scaffoldKey = GlobalKey();
  FilterSelectorOverlay? _filterSelectorOverlay;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistsListBloc>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: MtAppBar(context),
      body: BlocConsumer<ArtistsListBloc, ArtistsListState>(listener: (context, state) async {
        if (state.showFilterOverlay && _filterSelectorOverlay == null) {
          if (state.loadedDataAllTags.loadingStatus.isSuccess) {
            _filterSelectorOverlay = await _displayFilterBottomSheet(context, state.allTags!, state.filterTags, bloc);
          } else {
            _filterSelectorOverlay = null;
            // TODO Further error handling?
          }
        } else if (!state.showFilterOverlay && _filterSelectorOverlay != null) {
          // TODO Close filter overlay
        }
      }, builder: (context, state) {
        return LoadedDataDisplayWrapper<ArtistsList>(
            loadedData: state.loadedDataFilteredArtists,
            additionalCheckData: state.loadedDataAllTags,
            captionForError: 'Artists could not be loaded',
            captionForEmptyData: state.filterTags.isEmpty ? 'No artists yet' : 'No artists match the selected filters',
            buildOnSuccess: (filteredArtistsList) => ListView.separated(
                  separatorBuilder: (context, _) => Divider(),
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredArtistsList.isNotEmpty ? filteredArtistsList.length : 0,
                  itemBuilder: (context, i) {
                    return _buildArtistRow(context, filteredArtistsList[i], bloc);
                  },
                ));
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              onPressed: () => bloc.add(ToggleFilterOverlay()),
              child: const Icon(Icons.filter_list),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              heroTag: 'fab_change_filters'),
          SizedBox(
            height: 16,
          ),
          FloatingActionButton(
              onPressed: () => bloc.add(ToggleTagSubtitles()),
              child: _buildTagSubtitlesToggleIcon(),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              heroTag: 'fab_toggle_tag_subtitles'),
          SizedBox(
            height: 16,
          ),
          FloatingActionButton(
            onPressed: () =>
                AddEntityDialog.openAddArtistDialog(context, onSendInput: (input) => bloc.add(CreateArtists(input))),
            child: const Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          )
        ],
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.artists),
    );
  }

  Widget _buildTagSubtitlesToggleIcon() {
    return BlocBuilder<ArtistsListBloc, ArtistsListState>(
        builder: (context, state) => state.displayTagSubtitles ? const Icon(Icons.label_off) : const Icon(Icons.label));
  }

  Widget _buildArtistRow(BuildContext context, ArtistData artistWithTags, ArtistsListBloc bloc) {
    final handleDeleteArtist = () {
      bloc.add(DeleteArtist(artistWithTags.artist));
    };
    return ListTile(
        title: Text(
          artistWithTags.artist.name,
          style: listEntryStyle,
        ),
        subtitle: bloc.state.displayTagSubtitles ? _buildTagsSubtitle(context, artistWithTags) : null,
        onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artistWithTags.artist.id),
        onLongPress: () => DeleteDialog.openNew<Artist>(_scaffoldKey.currentContext!,
            entityToDelete: artistWithTags.artist, deleteHandler: handleDeleteArtist));
  }

  Widget _buildTagsSubtitle(BuildContext context, ArtistData artistWithTags) {
    return SizedBox(
        height: 40,
        child: Wrap(
          clipBehavior: Clip.hardEdge,
          alignment: WrapAlignment.start,
          children: artistWithTags.tags.map((tag) => _getTagChipWithPadding(context, tag)).toList(),
        ));
  }

  Widget _getTagChipWithPadding(BuildContext context, Tag tag) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.0),
        child: InputChip(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          padding: EdgeInsets.symmetric(horizontal: 6.0),
          labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
          label: Text(tag.name),
          labelStyle: tagChipLabelStyle,
          disabledColor: Theme.of(context).colorScheme.surface,
          onPressed: () => {},
        ));
  }

  Future<FilterSelectorOverlay?> _displayFilterBottomSheet(
      BuildContext context, TagsList allTagsList, Set<Tag> filterTags, ArtistsListBloc bloc) {
    return showMaterialModalBottomSheet<FilterSelectorOverlay>(
      context: context,
      expand: false,
      enableDrag: false,
      builder: (context) => FilterSelectorOverlay(
          entitiesWithInitialSelection: _getSelectionForFilterOverlay(allTagsList, filterTags),
          onClose: () => _onCloseModal(bloc)),
    );
  }

  void _onCloseModal(ArtistsListBloc bloc) {
    bloc.add(ToggleFilterOverlay());
  }

  Map<String, bool> _getSelectionForFilterOverlay(TagsList allTagsList, Set<Tag> filterTags) =>
      Map<String, bool>.fromIterable(allTagsList,
          key: (tagData) => tagData.tag.name, value: (tagData) => filterTags.contains(tagData.tag));
}
