import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moodtag/components/chip_cloud/chip_cloud.dart';
import 'package:moodtag/components/chip_cloud/chip_cloud_options.dart';
import 'package:moodtag/components/filter_selection_modal.dart';
import 'package:moodtag/components/loaded_data_display_wrapper.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_state.dart';
import 'package:moodtag/model/blocs/types.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/library_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/navigation/routes.dart';

class ArtistsListScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ArtistsListScreen(this.scaffoldKey);

  @override
  State<StatefulWidget> createState() => _ArtistsListScreenState();
}

class _ArtistsListScreenState extends State<ArtistsListScreen> with RouteAware {
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  static const tagChipLabelStyle = TextStyle(fontSize: 10.0, color: Colors.black87);

  late final RouteObserver _routeObserver;
  FilterSelectionModal? _filterSelectionModal;
  bool _filterDisplayOverlayVisible = false;
  OverlayEntry? _filterDisplayOverlay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = context.read<RouteObserver>();
    _routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    final bloc = context.read<ArtistsListBloc>();
    bloc.add(ActiveScreenChanged(true));
  }

  @override
  void didPopNext() {
    final bloc = context.read<ArtistsListBloc>();
    bloc.add(ActiveScreenChanged(true));
  }

  @override
  void didPop() {
    final bloc = context.read<ArtistsListBloc>();
    bloc.add(ActiveScreenChanged(false));
  }

  @override
  void didPushNext() {
    final bloc = context.read<ArtistsListBloc>();
    bloc.add(ActiveScreenChanged(false));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistsListBloc>();
    return BlocConsumer<ArtistsListBloc, ArtistsListState>(
        listener: (context, state) => _checkFilterModalAndOverlayState(context, state, bloc),
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
        });
  }

  void _checkFilterModalAndOverlayState(BuildContext context, ArtistsListState state, ArtistsListBloc bloc) {
    _checkFilterModalState(context, state, bloc);
    _checkFilterDisplayOverlayState(context, state);
  }

  void _checkFilterModalState(BuildContext context, ArtistsListState state, ArtistsListBloc bloc) async {
    if (_filterSelectionModal == null) {
      if (state.filterSelectionModalState == ModalState.opening && state.loadedDataAllTags.loadingStatus.isSuccess) {
        bloc.add(FilterSelectionModalStateChanged(open: true));
        _filterSelectionModal = await _displayFilterBottomSheet(context, state.allTags!, state.filterTags, bloc);
      } else if (state.filterSelectionModalState == ModalState.closing) {
        bloc.add(FilterSelectionModalStateChanged(open: false));
      }
    }
  }

  void _checkFilterDisplayOverlayState(BuildContext context, ArtistsListState state) {
    if (state.filterDisplayOverlayState == OverlayVisibility.on && !_filterDisplayOverlayVisible) {
      _showFilterDisplayOverlay(context, state.filterTags);
    } else if (state.filterDisplayOverlayState != OverlayVisibility.on && _filterDisplayOverlayVisible) {
      _hideFilterDisplayOverlay(context);
    }
  }

  void _showFilterDisplayOverlay(BuildContext context, Set<Tag> filterTags) {
    _filterDisplayOverlayVisible = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _filterDisplayOverlay = OverlayEntry(builder: (context) {
        final overlayWidth = MediaQuery.of(context).size.width * 0.75;
        final overlayHeight = MediaQuery.of(context).size.height * 0.20;
        return Positioned(
          left: MediaQuery.of(context).size.width * 0.05,
          bottom: MediaQuery.of(context).size.height * 0.13,
          child: Material(
              color: Colors.transparent,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ChipCloud<String>(
                      data: filterTags.map((tag) => tag.name).toList(),
                      constraints: Size(overlayWidth, overlayHeight),
                      options: ChipCloudOptions(elementSpacing: 8, padding: EdgeInsets.all(8), debug: false)))),
        );
      });
      Overlay.of(context).insert(_filterDisplayOverlay!);
    });
  }

  void _hideFilterDisplayOverlay(BuildContext context) {
    _filterDisplayOverlayVisible = false;
    _filterDisplayOverlay?.remove();
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
        subtitle: bloc.state.displayTagSubtitles && artistWithTags.tags.isNotEmpty
            ? _buildTagsSubtitle(context, artistWithTags)
            : null,
        onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artistWithTags.artist.id),
        onLongPress: () => DeleteDialog.openNew<Artist>(widget.scaffoldKey.currentContext!,
            entityToDelete: artistWithTags.artist, deleteHandler: handleDeleteArtist));
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
