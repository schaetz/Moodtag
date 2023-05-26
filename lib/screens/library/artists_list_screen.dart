import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moodtag/components/chip_cloud.dart';
import 'package:moodtag/components/filter_selection_modal.dart';
import 'package:moodtag/components/loaded_data_display_wrapper.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_state.dart';
import 'package:moodtag/model/blocs/modal_state.dart';
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
  FilterSelectionModal? _filterSelectionModal;
  OverlayEntry? _filterDisplayOverlay;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistsListBloc>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: MtAppBar(context),
      body: BlocConsumer<ArtistsListBloc, ArtistsListState>(
          listener: (context, state) => _checkFilterSelectionModalState(state, bloc),
          builder: (context, state) {
            return LoadedDataDisplayWrapper<ArtistsList>(
                loadedData: state.loadedDataFilteredArtists,
                additionalCheckData: state.loadedDataAllTags,
                captionForError: 'Artists could not be loaded',
                captionForEmptyData:
                    state.filterTags.isEmpty ? 'No artists yet' : 'No artists match the selected filters',
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
              onPressed: () => bloc.add(ToggleFilterSelectionModal(wantedOpen: true)),
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

  void _checkFilterSelectionModalState(ArtistsListState state, ArtistsListBloc bloc) async {
    if (_filterSelectionModal == null) {
      if (state.filterSelectionModalState == ModalState.opening && state.loadedDataAllTags.loadingStatus.isSuccess) {
        bloc.add(FilterSelectionModalStateChanged(open: true));
        _hideFilterDisplayOverlay(context);
        _filterSelectionModal = await _displayFilterBottomSheet(context, state.allTags!, state.filterTags, bloc);
      } else if (state.filterSelectionModalState == ModalState.closing) {
        bloc.add(FilterSelectionModalStateChanged(open: false));
        if (state.filterTags.isNotEmpty) {
          _showFilterDisplayOverlay(state.filterTags);
        }
      }
    }
  }

  void _showFilterDisplayOverlay(Set<Tag> filterTags) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _filterDisplayOverlay = OverlayEntry(builder: (context) {
        final overlayWidth = MediaQuery.of(context).size.width * 0.75;
        final overlayHeight = MediaQuery.of(context).size.height * 0.20;
        return Positioned(
          left: MediaQuery.of(context).size.width * 0.05,
          bottom: MediaQuery.of(context).size.height * 0.10,
          child: Material(
              color: Colors.transparent,
              child: SizedBox(
                  width: overlayWidth,
                  height: overlayHeight,
                  child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: ChipCloud(
                        captions: filterTags.map((tag) => tag.name).toList(),
                        constraints: Size(overlayWidth, overlayHeight),
                        elementSpacing: 8,
                        padding: EdgeInsets.all(8),
                        debug: true,
                      )))),
        );
      });
      Overlay.of(context)?.insert(_filterDisplayOverlay!);
    });
  }

  List<Widget> _buildFilterDisplayChips(Set<Tag> filterTags) {
    return filterTags
        .map((tag) => InputChip(
              label: Text(tag.name),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ))
        .toList();
  }

  void _hideFilterDisplayOverlay(BuildContext context) {
    _filterDisplayOverlay?.remove();
    _filterDisplayOverlay = null;
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

  Future<FilterSelectionModal?> _displayFilterBottomSheet(
      BuildContext context, TagsList allTagsList, Set<Tag> filterTags, ArtistsListBloc bloc) {
    return showMaterialModalBottomSheet<FilterSelectionModal>(
      context: context,
      expand: false,
      enableDrag: false,
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
