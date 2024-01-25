import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/library/main_screen/artists_list/artists_list_bloc.dart';
import 'package:moodtag/features/library/main_screen/artists_list/artists_list_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog.dart';
import 'package:moodtag/shared/models/modal_and_overlay_types.dart';
import 'package:moodtag/shared/widgets/data_display/chip_cloud/chip_cloud.dart';
import 'package:moodtag/shared/widgets/data_display/chip_cloud/chip_cloud_options.dart';
import 'package:moodtag/shared/widgets/data_display/loaded_data_display_wrapper.dart';
import 'package:moodtag/shared/widgets/modals/filter_selection_modal.dart';
import 'package:moodtag/shared/widgets/screen_extensions/searchable_list_screen_mixin.dart';
import 'package:moodtag/shared/widgets/text_input/search_bar_container.dart';

class ArtistsListScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TabController parentTabController;
  final int parentTabViewIndex;

  const ArtistsListScreen(this.scaffoldKey, {required this.parentTabController, required this.parentTabViewIndex});

  @override
  State<StatefulWidget> createState() => _ArtistsListScreenState();
}

class _ArtistsListScreenState extends State<ArtistsListScreen> with SearchableListScreenMixin<ArtistsListBloc> {
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  static const tagChipLabelStyle = TextStyle(fontSize: 10.0, color: Colors.black87);

  final GlobalKey listViewKey = GlobalKey();

  FilterSelectionModal? _filterSelectionModal;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistsListBloc>();
    return BlocConsumer<ArtistsListBloc, ArtistsListState>(
        listener: (context, state) => _checkFilterModalState(context, state, bloc),
        builder: (context, state) {
          return SearchBarContainer(
            searchBarHintText: 'Search artist',
            searchBarVisible: state.displaySearchBar,
            onSearchBarTextChanged: (value) => onSearchBarTextChanged(value, bloc),
            onSearchBarClosed: () => onSearchBarClosed(bloc),
            contentWidget: Stack(children: [
              LoadedDataDisplayWrapper<ArtistsList>(
                  loadedData: state.loadedDataFilteredArtists,
                  additionalCheckData: state.allTags,
                  captionForError: 'Artists could not be loaded',
                  captionForEmptyData: state.filterTags.isEmpty && (!state.displaySearchBar || state.searchItem.isEmpty)
                      ? 'No artists yet'
                      : 'No artists match the selected filters',
                  buildOnSuccess: (filteredArtistsList) => ListView.separated(
                        separatorBuilder: (context, _) => Divider(),
                        padding: EdgeInsets.all(16.0),
                        itemCount: filteredArtistsList.isNotEmpty ? filteredArtistsList.length : 0,
                        itemBuilder: (context, i) {
                          return _buildArtistRow(context, filteredArtistsList[i], bloc);
                        },
                      )),
              state.displayFilterDisplayOverlay
                  ? _buildFilterDisplayOverlay(context, state.filterTags, bloc)
                  : Container()
            ]),
            listViewKey: listViewKey,
          );
        });
  }

  void _checkFilterModalState(BuildContext context, ArtistsListState state, ArtistsListBloc bloc) async {
    if (_filterSelectionModal == null) {
      if (state.filterSelectionModalState == ModalState.opening && state.allTags.loadingStatus.isSuccess) {
        bloc.add(FilterSelectionModalStateChanged(open: true));
        _filterSelectionModal = await _displayFilterBottomSheet(context, state.allTags.data!, state.filterTags, bloc);
      } else if (state.filterSelectionModalState == ModalState.closing) {
        bloc.add(FilterSelectionModalStateChanged(open: false));
      }
    }
  }

  Widget _buildFilterDisplayOverlay(BuildContext context, Set<Tag> filterTags, ArtistsListBloc bloc) {
    final screenSize = MediaQuery.of(context).size;
    final overlaySize = Size(screenSize.width * 0.9, screenSize.height * 0.2);
    final iconClose = Icon(Icons.close);
    final iconSize = 45;

    return Stack(children: [
      Positioned(
        right: (screenSize.width - overlaySize.width) / 2,
        bottom: overlaySize.height * 0.1,
        child: _buildFilterDisplayChipCloud(filterTags, overlaySize.width, overlaySize.height),
      ),
      Positioned(
          right: (screenSize.width - overlaySize.width) / 2 - iconSize / 2,
          bottom: overlaySize.height * 1.1 - iconSize / 2,
          child: IconButton.filled(
            icon: iconClose,
            style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
            onPressed: () => bloc.add(RemoveArtistsListFilters()),
          )),
    ]);
  }

  Material _buildFilterDisplayChipCloud(Set<Tag> filterTags, double overlayWidth, double overlayHeight) {
    return Material(
        color: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ChipCloud<String>(
                data: filterTags.map((tag) => tag.name).toList(),
                constraints: Size(overlayWidth, overlayHeight),
                options: ChipCloudOptions(elementSpacing: 8, padding: EdgeInsets.all(8), debug: false))));
  }

  Widget _buildArtistRow(BuildContext context, ArtistData artistWithTags, ArtistsListBloc bloc) {
    final handleDeleteArtist = (bool confirmation) {
      if (confirmation) bloc.add(DeleteArtist(artistWithTags.artist));
    };
    return ListTile(
        title: Text(
          artistWithTags.artist.name,
          style: listEntryStyle,
        ),
        subtitle: bloc.state.displayTagSubtitles && artistWithTags.tags.isNotEmpty
            ? _buildTagsSubtitle(context, artistWithTags)
            : null,
        onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artistWithTags.artist.id),
        onLongPress: () => DeleteEntityDialog.construct<Artist>(widget.scaffoldKey.currentContext!,
            entityToDelete: artistWithTags.artist, handleResult: handleDeleteArtist)
          ..show());
  }

  Widget _buildTagsSubtitle(BuildContext context, ArtistData artistWithTags) {
    return SizedBox(
        height: 42,
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
          onPressed: () => {},
        ));
  }

  Future<FilterSelectionModal?> _displayFilterBottomSheet(
      BuildContext context, TagsList allTagsList, Set<Tag> filterTags, ArtistsListBloc bloc) {
    return showMaterialModalBottomSheet<FilterSelectionModal>(
      context: context,
      expand: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      )),
      builder: (context) => FilterSelectionModal<TagData>(
          entitiesWithInitialSelection: _getSelectionForFilterOverlay(allTagsList, filterTags),
          onConfirmSelection: (Set<TagData> newFilterTagsData) =>
              _onConfirmFilterChanges(newFilterTagsData.map((tagData) => tagData.tag).toSet(), bloc),
          onCloseModal: () => _onCloseModal(bloc)),
    );
  }

  void _onConfirmFilterChanges(Set<Tag> newFilterTags, ArtistsListBloc bloc) {
    bloc.add(ChangeArtistsListFilters(filterTags: newFilterTags));
  }

  void _onCloseModal(ArtistsListBloc bloc) {
    bloc.add(ToggleFilterSelectionModal(wantedOpen: false));
  }

  Map<TagData, bool> _getSelectionForFilterOverlay(TagsList allTagsList, Set<Tag> filterTags) =>
      Map<TagData, bool>.fromIterable(allTagsList,
          key: (tagData) => tagData, value: (tagData) => filterTags.contains(tagData.tag));
}
