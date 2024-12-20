import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/library/details_screens/artist_details/artist_details_bloc.dart';
import 'package:moodtag/features/library/details_screens/artist_details/artist_details_state.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/bloc/events/spotify_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';
import 'package:moodtag/shared/dialogs/alert_dialog_factory.dart';
import 'package:moodtag/shared/widgets/data_display/chips_row_info_label.dart';
import 'package:moodtag/shared/widgets/data_display/loaded_data_display_wrapper.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_main_scaffold.dart';

class ArtistDetailsScreen extends StatelessWidget {
  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  ArtistDetailsScreen();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistDetailsBloc>();
    final dialogFactory = context.read<AlertDialogFactory>();

    return MtMainScaffold(
        scaffoldKey: _scaffoldKey,
        pageWidget: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ArtistDetailsBloc, ArtistDetailsState>(
            builder: (context, state) {
              return LoadedDataDisplayWrapper<Artist>(
                  loadedData: state.loadedArtist,
                  captionForError: 'Artist could not be loaded',
                  captionForEmptyData: 'Artist does not exist',
                  buildOnSuccess: (artist) => ListView(children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: _buildHeadline(context, state),
                        ),
                        if (artist.spotifyId != null)
                          Padding(
                              padding: EdgeInsets.only(bottom: 8.0), child: Text('Spotify ID: ' + artist.spotifyId!)),
                        if (artist.spotifyId != null)
                          Padding(
                              padding: EdgeInsets.only(bottom: 12.0),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green),
                                      foregroundColor: MaterialStateColor.resolveWith((states) => Colors.white)),
                                  child: Text('Play on Spotify'),
                                  onPressed: () => bloc.add(PlayArtist(artist)))), // TODO Implement event mapper
                        _buildTagChipsRow(context, state, dialogFactory),
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

  Widget _buildHeadline(BuildContext context, ArtistDetailsState state) => RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(Icons.library_music),
            ),
            WidgetSpan(
              child: SizedBox(width: 4),
            ),
            TextSpan(
                text: state.loadedArtist.data?.name ?? 'Unknown tag',
                style: artistNameStyle.copyWith(color: Theme.of(context).colorScheme.onBackground)),
          ],
        ),
      );

  void _toggleEditMode(BuildContext context) {
    context.read<ArtistDetailsBloc>().add(ToggleTagEditMode());
  }

  Widget _buildTagChipsRow(BuildContext context, ArtistDetailsState state, AlertDialogFactory dialogFactory) {
    if (state.tagEditMode) {
      if (state.allTags.loadingStatus.isError || state.allTags.data == null) {
        return ChipsRowInfoLabel('Error loading the tags');
      } else if (state.loadedArtist.data == null) {
        return ChipsRowInfoLabel('Something went wrong');
      }
    } else {
      // TODO Improve loading / error labels
      if (state.loadedArtist.loadingStatus.isInitialOrLoading) {
        return ChipsRowInfoLabel('Loading tags...');
      }
      if (state.loadedArtist.loadingStatus.isError || state.loadedArtist.data == null) {
        return ChipsRowInfoLabel('Error loading the tags for the artist');
      }
    }

    final artist = state.loadedArtist.data!;
    List<BaseTag> tagsToDisplay =
        state.tagEditMode ? _convertTagDataListToTagList(state.allTags.data!) : artist.tags.toList();

    List<Widget> chipsList =
        tagsToDisplay.map((tag) => _buildTagChip(context, state.tagEditMode, artist, tag, (_value) {})).toList();
    if (state.tagEditMode) {
      chipsList.add(_buildAddTagChip(context, artist, dialogFactory));
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: chipsList,
    );
  }

  // TODO Maybe find a less costly solution
  List<Tag> _convertTagDataListToTagList(List<Tag> tagList) => tagList.map((tag) => tag).toList();

  Widget _buildTagChip(
      BuildContext context, bool tagEditMode, Artist artist, BaseTag tag, ValueChanged<BaseTag> onTapped) {
    return InputChip(
        label: Text(tag.name),
        selected: tagEditMode && artist.tags.containsEntity(tag),
        onPressed: () => _onTagChipPressed(context, artist, tag, tagEditMode, onTapped));
  }

  void _onTagChipPressed(
      BuildContext context, Artist artist, BaseTag tag, bool tagEditMode, ValueChanged<BaseTag> onTapped) async {
    if (tagEditMode) {
      context.read<ArtistDetailsBloc>().add(ToggleTagForArtist(artist, tag));
    } else {
      onTapped(tag);
    }
  }

  Widget _buildAddTagChip(BuildContext context, Artist artist, AlertDialogFactory dialogFactory) {
    final bloc = context.read<ArtistDetailsBloc>();
    return InputChip(
      label: Text('+'),
      onPressed: () => dialogFactory
          .getSingleTextInputDialog(context,
              title: 'Create new tag(s)',
              subtitle: 'Separate multiple tags by line breaks',
              multiline: true,
              maxLines: 10)
          .show(onTruthyResult: (input) => bloc.add(CreateTags(input!, preselectedArtist: artist))),
    );
  }
}
