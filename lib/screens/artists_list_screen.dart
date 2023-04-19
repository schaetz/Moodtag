import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_state.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/navigation/navigation_item.dart';
import 'package:moodtag/navigation/routes.dart';

class ArtistsListScreen extends StatelessWidget {
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  GlobalKey _scaffoldKey = GlobalKey();

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
          if (state.artists.isEmpty) {
            return const Align(
              alignment: Alignment.center,
              child: Text('No artists yet', style: listEntryStyle),
            );
          }

          return ListView.separated(
            separatorBuilder: (context, _) => Divider(),
            padding: EdgeInsets.all(16.0),
            itemCount: state.artists.isNotEmpty ? state.artists.length : 0,
            itemBuilder: (context, i) {
              return _buildArtistRow(context, state.artists[i], bloc);
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

  Widget _buildArtistRow(BuildContext context, Artist artist, ArtistsListBloc bloc) {
    final handleDeleteArtist = (Artist artist) {
      bloc.add(DeleteArtist(artist));
    };
    return ListTile(
        title: Text(
          artist.name,
          style: listEntryStyle,
        ),
        onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artist.id),
        onLongPress: () => DeleteDialog.openNew<Artist>(_scaffoldKey.currentContext!,
            entityToDelete: artist, deleteHandler: handleDeleteArtist));
  }
}
