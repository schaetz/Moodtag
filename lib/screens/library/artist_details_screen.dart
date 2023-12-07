import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/chips_row_info_label.dart';
import 'package:moodtag/components/loaded_data_display_wrapper.dart';
import 'package:moodtag/components/mt_main_scaffold.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/model/blocs/artist_details/artist_details_bloc.dart';
import 'package:moodtag/model/blocs/artist_details/artist_details_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/spotify_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class ArtistDetailsScreen extends StatelessWidget {
  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  ArtistDetailsScreen();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistDetailsBloc>();
    return MtMainScaffold(
        scaffoldKey: _scaffoldKey,
        pageWidget: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ArtistDetailsBloc, ArtistDetailsState>(
            builder: (context, state) {
              return LoadedDataDisplayWrapper<ArtistData>(
                  loadedData: state.loadedArtistData,
                  captionForError: 'Artist could not be loaded',
                  captionForEmptyData: 'Artist does not exist',
                  buildOnSuccess: (artistData) => ListView(children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Text(artistData.artist.name, style: ArtistDetailsScreen.artistNameStyle),
                        ),
                        if (artistData.artist.spotifyId != null)
                          Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text('Spotify ID: ' + artistData.artist.spotifyId!)),
                        if (artistData.artist.spotifyId != null)
                          Padding(
                              padding: EdgeInsets.only(bottom: 12.0),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green),
                                      foregroundColor: MaterialStateColor.resolveWith((states) => Colors.white)),
                                  child: Text('Play on Spotify'),
                                  onPressed: () => bloc.add(PlayArtist(artistData)))), // TODO Implement event mapper
                        _buildTagChipsRow(context, state),
                        Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                                child: Text(state.tagEditMode ? 'Finish editing' : 'Edit tags'),
                                onPressed: () => _toggleEditMode(context))),
                      ]));
            },
          ),
        ));
  }

  void _toggleEditMode(BuildContext context) {
    context.read<ArtistDetailsBloc>().add(ToggleTagEditMode());
  }

  Widget _buildTagChipsRow(BuildContext context, ArtistDetailsState state) {
    if (state.tagEditMode) {
      if (state.loadedDataAllTags.loadingStatus.isError || state.loadedDataAllTags.data == null) {
        return ChipsRowInfoLabel('Error loading the tags');
      } else if (state.loadedArtistData.data == null) {
        return ChipsRowInfoLabel('Something went wrong');
      }
    } else {
      // TODO Improve loading / error labels
      if (state.loadedArtistData.loadingStatus.isInitialOrLoading) {
        return ChipsRowInfoLabel('Loading tags...');
      }
      if (state.loadedArtistData.loadingStatus.isError || state.loadedArtistData.data == null) {
        return ChipsRowInfoLabel('Error loading the tags for the artist');
      }
    }

    final ArtistData artistData = state.loadedArtistData.data!;
    List<Tag> tagsToDisplay =
        state.tagEditMode ? _convertTagDataListToTagList(state.loadedDataAllTags.data!) : artistData.tags.toList();

    List<Widget> chipsList =
        tagsToDisplay.map((tag) => _buildTagChip(context, state.tagEditMode, artistData, tag, (_value) {})).toList();
    if (state.tagEditMode) {
      chipsList.add(_buildAddTagChip(context, artistData));
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: chipsList,
    );
  }

  // TODO Maybe find a less costly solution
  List<Tag> _convertTagDataListToTagList(List<TagData> tagDataList) =>
      tagDataList.map((tagData) => tagData.tag).toList();

  Widget _buildTagChip(
      BuildContext context, bool tagEditMode, ArtistData artistData, Tag tag, ValueChanged<Tag> onTapped) {
    return InputChip(
        label: Text(tag.name),
        selected: tagEditMode && artistData.tags.contains(tag),
        onPressed: () => _onTagChipPressed(context, artistData.artist, tag, tagEditMode, onTapped));
  }

  void _onTagChipPressed(
      BuildContext context, Artist artist, Tag tag, bool tagEditMode, ValueChanged<Tag> onTapped) async {
    if (tagEditMode) {
      context.read<ArtistDetailsBloc>().add(ToggleTagForArtist(artist, tag));
    } else {
      onTapped(tag);
    }
  }

  Widget _buildAddTagChip(BuildContext context, ArtistData artistData) {
    final bloc = context.read<ArtistDetailsBloc>();
    return InputChip(
      label: Text('+'),
      onPressed: () => AddEntityDialog.openAddTagDialog(
        context,
        preselectedArtist: artistData.artist,
        onSendInput: (input) => bloc.add(CreateTags(input, preselectedArtist: artistData.artist)),
      ),
    );
  }
}
