import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/model/blocs/artist_details/artist_details_bloc.dart';
import 'package:moodtag/model/blocs/artist_details/artist_details_state.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:provider/provider.dart';

class ArtistDetailsScreen extends StatelessWidget {
  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const infoLabelStyle = TextStyle(fontSize: 18.0);

  const ArtistDetailsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MtAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ArtistDetailsBloc, ArtistDetailsState>(
            // TODO Show loading or error symbols
            buildWhen: (previous, current) =>
                current.artistLoadingStatus.isSuccess &&
                current.tagsListLoadingStatus.isSuccess, // TODO Show artist even when tags list is not available
            builder: (context, state) {
              return ListView(children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(state.artist.name, style: ArtistDetailsScreen.artistNameStyle),
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
      // TODO When in tag edit mode, only build the widget if the complete list of tags was loaded
    } else {
      // TODO Improve loading / error labels
      if (state.tagsListLoadingStatus.isInitialOrLoading) {
        return const Align(
          alignment: Alignment.center,
          child: Text('Loading tags...', style: infoLabelStyle),
        );
      }
      if (state.artistLoadingStatus.isError || state.tagsForArtist == null) {
        return const Align(
          alignment: Alignment.center,
          child: Text('Error loading the tags for the artist', style: infoLabelStyle),
        );
      }
    }

    List<Tag> tagsToDisplay =
        state.tagEditMode ? state.tagsForArtist : state.tagsForArtist; // TODO Show all tags in tag edit mode

    List<Widget> chipsList = tagsToDisplay.map((tag) => _buildTagChip(context, state, tag, (value) {})).toList();
    if (state.tagEditMode) {
      chipsList.add(_buildAddTagChip(context, state.artist));
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: chipsList,
    );
  }

  Widget _buildTagChip(BuildContext context, ArtistDetailsState state, Tag tag, ValueChanged<Tag> onTapped) {
    return InputChip(
        label: Text(tag.name),
        selected: state.tagEditMode && state.tagsForArtist.contains(tag),
        onPressed: () => _onTagChipPressed(context, state, tag, onTapped));
  }

  void _onTagChipPressed(BuildContext context, ArtistDetailsState state, Tag tag, ValueChanged<Tag> onTapped) async {
    if (state.tagEditMode) {
      final bloc = Provider.of<Repository>(context, listen: false);

      if (state.tagsForArtist.contains(tag)) {
        await bloc.removeTagFromArtist(state.artist, tag);
      } else {
        await bloc.assignTagToArtist(state.artist, tag);
      }
    } else {
      onTapped(tag);
    }
  }

  Widget _buildAddTagChip(BuildContext context, Artist artist) {
    return InputChip(
        label: Text('+'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => AddEntityDialog.openAddTagDialog<ArtistDetailsBloc>(context, preselectedArtist: artist));
  }
}
