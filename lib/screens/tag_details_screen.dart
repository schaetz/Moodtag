import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/remove_tag_from_artist_dialog.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/blocs/tag_details/tag_details_bloc.dart';
import 'package:moodtag/model/blocs/tag_details/tag_details_state.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/navigation/routes.dart';

class TagDetailsScreen extends StatelessWidget {
  static const tagNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  final GlobalKey _scaffoldKey = GlobalKey();

  TagDetailsScreen();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TagDetailsBloc>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: MtAppBar(context),
      body: BlocBuilder<TagDetailsBloc, TagDetailsState>(
        buildWhen: (previous, current) =>
            // TODO Show loading or error symbols
            current.tagLoadingStatus.isSuccess &&
            current.artistsListLoadingStatus.isSuccess, // TODO Show tag even when artists list is not available
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: state.tag != null && state.artistsWithTag != null
                    ? Text(state.tag!.name + ' (' + state.artistsWithTag!.length.toString() + ')', style: tagNameStyle)
                    : Text(''),
              ),
              Expanded(child: Builder(builder: (BuildContext context) {
                if (state.artistsWithTag == null || state.tag == null) {
                  return Container(); // TODO Show loading symbol or somethink alike
                } else if (state.artistsWithTag!.isEmpty) {
                  return const Align(
                    alignment: Alignment.center,
                    child: Text('No artists with this tag', style: listEntryStyle),
                  );
                }

                return ListView.separated(
                  separatorBuilder: (context, _) => Divider(),
                  padding: EdgeInsets.all(16.0),
                  itemCount: state.artistsWithTag!.length,
                  itemBuilder: (context, i) {
                    return _buildArtistRow(context, state.tag!, state.artistsWithTag![i], bloc);
                  },
                );
              })),
            ]),
          );
        },
      ),
      floatingActionButton: BlocBuilder<TagDetailsBloc, TagDetailsState>(
          buildWhen: (previous, current) => current.tagLoadingStatus.isSuccess,
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: () => AddEntityDialog.openAddArtistDialog(context,
                  preselectedTag: state.tag, onSendInput: (input) => bloc.add(AddArtistsForTag(input, state.tag!))),
              child: const Icon(Icons.add),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            );
          }),
    );
  }

  // TODO Replace state parameter by non-nullable parameters for individual properties
  Widget _buildArtistRow(BuildContext context, Tag tag, Artist artist, TagDetailsBloc bloc) {
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
