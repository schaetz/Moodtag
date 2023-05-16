import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_state.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/navigation/navigation_item.dart';
import 'package:moodtag/navigation/routes.dart';

class ArtistsListScreen extends StatelessWidget {
  static const listEntryStyle = TextStyle(fontSize: 18.0);
  static const tagChipLabelStyle = TextStyle(fontSize: 10.0, color: Colors.black87);

  final GlobalKey _scaffoldKey = GlobalKey();

  ArtistsListScreen();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistsListBloc>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: MtAppBar(context),
      body: BlocBuilder<ArtistsListBloc, ArtistsListState>(
        buildWhen: (previous, current) => current.loadingStatus.isSuccess, // TODO Show loading or error symbols
        builder: (context, state) {
          if (state.artistsWithTags.isEmpty) {
            return const Align(
              alignment: Alignment.center,
              child: Text('No artists yet', style: listEntryStyle),
            );
          }

          return ListView.separated(
            separatorBuilder: (context, _) => Divider(),
            padding: EdgeInsets.all(16.0),
            itemCount: state.artistsWithTags.isNotEmpty ? state.artistsWithTags.length : 0,
            itemBuilder: (context, i) {
              return _buildArtistRow(context, state.artistsWithTags[i], bloc);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            AddEntityDialog.openAddArtistDialog(context, onSendInput: (input) => bloc.add(CreateArtists(input))),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.artists),
    );
  }

  Widget _buildArtistRow(BuildContext context, ArtistWithTags artistWithTags, ArtistsListBloc bloc) {
    final handleDeleteArtist = () {
      bloc.add(DeleteArtist(artistWithTags.artist));
    };
    return ListTile(
        title: Text(
          artistWithTags.artist.name,
          style: listEntryStyle,
        ),
        subtitle: _buildTagsSubtitle(context, artistWithTags),
        onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artistWithTags.artist.id),
        onLongPress: () => DeleteDialog.openNew<Artist>(_scaffoldKey.currentContext!,
            entityToDelete: artistWithTags.artist, deleteHandler: handleDeleteArtist));
  }

  Widget _buildTagsSubtitle(BuildContext context, ArtistWithTags artistWithTags) {
    return SizedBox(
        height: 40,
        child: Wrap(
          clipBehavior: Clip.hardEdge,
          children: artistWithTags.tags.map((tag) => _getTagChipWithPadding(context, tag)).toList(),
        ));
  }

  Widget _getTagChipWithPadding(BuildContext context, Tag tag) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.0),
        child: InputChip(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          padding: EdgeInsets.symmetric(horizontal: 6.0),
          labelPadding: EdgeInsets.all(0.0),
          label: Text(tag.name),
          labelStyle: tagChipLabelStyle,
          disabledColor: Theme.of(context).colorScheme.surface,
          onPressed: () => {},
        ));
  }
}
