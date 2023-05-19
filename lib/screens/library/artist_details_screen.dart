import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/model/blocs/artist_details/artist_details_bloc.dart';
import 'package:moodtag/model/blocs/artist_details/artist_details_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';

class ArtistDetailsScreen extends StatelessWidget {
  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const infoLabelStyle = TextStyle(fontSize: 18.0);

  final GlobalKey _scaffoldKey = GlobalKey();

  ArtistDetailsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: MtAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ArtistDetailsBloc, ArtistDetailsState>(
            // TODO Show loading or error symbols
            buildWhen: (previous, current) =>
                current.artistLoadingStatus.isSuccess &&
                current.tagsForArtistLoadingStatus.isSuccess &&
                current.isTagsListLoaded, // TODO Show artist even when tags list is not available
            builder: (context, state) {
              if (!state.artistLoadingStatus.isSuccess ||
                  state.artist == null ||
                  state.tagsForArtist == null ||
                  state.allTags == null) {
                return Container(); // TODO Show loading symbol or something alike
              }

              return ListView(children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(state.artist!.name, style: ArtistDetailsScreen.artistNameStyle),
                ),
                _buildTagChipsRow(context, state),
                Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: ElevatedButton(
                        child: Text(state.tagEditMode ? 'Finish editing' : 'Edit tags'),
                        onPressed: () => _toggleEditMode(context)))
              ]);
            },
          ),
        ));
  }

  void _toggleEditMode(BuildContext context) {
    context.read<ArtistDetailsBloc>().add(ToggleTagEditMode());
  }

  Widget _buildTagChipsRow(BuildContext context, ArtistDetailsState state) {
    if (state.tagEditMode) {
      if (state.loadedDataAllTags == null || state.loadedDataAllTags!.loadingStatus.isError || state.allTags == null) {
        return const Align(
          alignment: Alignment.center,
          child: Text('Error loading the tags', style: infoLabelStyle),
        );
      }
    } else {
      // TODO Improve loading / error labels
      if (state.tagsForArtistLoadingStatus.isInitialOrLoading) {
        return const Align(
          alignment: Alignment.center,
          child: Text('Loading tags...', style: infoLabelStyle),
        );
      }
      if (state.tagsForArtistLoadingStatus.isError || state.tagsForArtist == null) {
        return const Align(
          alignment: Alignment.center,
          child: Text('Error loading the tags for the artist', style: infoLabelStyle),
        );
      }
    }

    List<Tag> tagsToDisplay = state.tagEditMode ? _convertTagDataListToTagList(state.allTags!) : state.tagsForArtist!;

    List<Widget> chipsList = tagsToDisplay.map((tag) => _buildTagChip(context, state, tag, (_value) {})).toList();
    if (state.tagEditMode) {
      chipsList.add(_buildAddTagChip(context, state));
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

  Widget _buildTagChip(BuildContext context, ArtistDetailsState state, Tag tag, ValueChanged<Tag> onTapped) {
    return InputChip(
        label: Text(tag.name),
        selected: state.tagEditMode && state.tagsForArtist!.contains(tag),
        onPressed: () => _onTagChipPressed(context, state.artist!, tag, state.tagEditMode, onTapped));
  }

  void _onTagChipPressed(
      BuildContext context, Artist artist, Tag tag, bool tagEditMode, ValueChanged<Tag> onTapped) async {
    if (tagEditMode) {
      context.read<ArtistDetailsBloc>().add(ToggleTagForArtist(artist, tag));
    } else {
      onTapped(tag);
    }
  }

  Widget _buildAddTagChip(BuildContext context, ArtistDetailsState state) {
    final bloc = context.read<ArtistDetailsBloc>();
    return InputChip(
      label: Text('+'),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onPressed: () => AddEntityDialog.openAddTagDialog(
        context,
        preselectedArtist: state.artist,
        onSendInput: (input) => bloc.add(CreateTags(input, preselectedArtist: state.artist)),
      ),
    );
  }
}
