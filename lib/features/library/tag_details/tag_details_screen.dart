import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/loaded_data_display_wrapper.dart';
import 'package:moodtag/components/mt_main_scaffold.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/remove_tag_from_artist_dialog.dart';
import 'package:moodtag/features/library/tag_details/tag_details_bloc.dart';
import 'package:moodtag/features/library/tag_details/tag_details_state.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/shared/bloc/events/artist_events.dart';
import 'package:moodtag/shared/bloc/events/tag_events.dart';

class TagDetailsScreen extends StatelessWidget {
  static const tagNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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
                          child: _buildHeadline(tagData.tag, state.artistsWithThisTagOnly.data),
                        ),
                        Expanded(
                            child: LoadedDataDisplayWrapper<ArtistsList>(
                          loadedData: state.artistsWithThisTagOnly,
                          captionForError: 'Artists with this tag could not be loaded',
                          captionForEmptyData: 'No artists with this tag',
                          additionalCheckData: state.allArtists,
                          buildOnSuccess: (artistsWithThisTagOnly) => ListView.separated(
                            separatorBuilder: (context, _) => Divider(),
                            padding: EdgeInsets.all(4.0),
                            itemCount:
                                state.checklistMode ? state.allArtists.data!.length : artistsWithThisTagOnly.length,
                            itemBuilder: (context, i) {
                              return state.checklistMode
                                  ? _buildRowForArtistSelection(context, tagData.tag, state.allArtists.data![i], bloc)
                                  : _buildRowForAssociatedArtist(
                                      context, tagData.tag, artistsWithThisTagOnly[i].artist, bloc);
                            },
                          ),
                        )),
                      ])));
        },
      ),
      floatingActionButton: BlocBuilder<TagDetailsBloc, TagDetailsState>(builder: (context, state) {
        return LoadedDataDisplayWrapper<TagData>(
            loadedData: state.loadedTagData,
            additionalCheckData: state.allArtists,
            showPlaceholders: false,
            buildOnSuccess: (tagData) => _buildFloatingActionButtons(context, state.loadedTagData.data!.tag, bloc));
      }),
    );
  }

  Widget _buildHeadline(Tag tag, ArtistsList? artistsWithThisTagOnly) {
    String headlineText =
        artistsWithThisTagOnly == null ? tag.name : '${tag.name} (${artistsWithThisTagOnly.length.toString()})';
    return Text(headlineText, style: tagNameStyle);
  }

  Widget _buildFloatingActionButtons(BuildContext context, Tag tag, TagDetailsBloc bloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
            onPressed: () => bloc.add(ToggleArtistsForTagChecklist()),
            child: const Icon(Icons.ballot),
            heroTag: 'fab_checklist_mode'),
        SizedBox(
          height: 16,
        ),
        FloatingActionButton(
          onPressed: () => AddEntityDialog.openAddArtistDialog(context,
              preselectedTag: tag, onSendInput: (input) => bloc.add(AddArtistsForTag(input, tag))),
          child: const Icon(Icons.add),
        ),
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
