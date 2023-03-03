import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  const ArtistsListScreen();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ArtistsListBloc>();
    bloc.errorStreamController.stream.listen((event) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(event.message)));
      });
    });
    return Scaffold(
      appBar: MtAppBar(context),
      body: BlocConsumer<ArtistsListBloc, ArtistsListState>(
        listener: (context, state) {
          if (state.showCreateArtistDialog) {
            AddEntityDialog.openAddArtistDialog(context,
                onSendInput: (input) => bloc.add(CreateArtists(input)),
                onTerminate: (_) => bloc.add(CloseCreateArtistDialog()));
          }
        },
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
              return _buildArtistRow(context, state.artists[i]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<ArtistsListBloc>().add(OpenCreateArtistDialog()),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.artists),
    );
  }

  Widget _buildArtistRow(BuildContext context, Artist artist) {
    return ListTile(
        title: Text(
          artist.name,
          style: listEntryStyle,
        ),
        onTap: () => Navigator.of(context).pushNamed(Routes.artistsDetails, arguments: artist.id),
        onLongPress: () => DeleteDialog.openNew<Artist>(context, entityToDelete: artist));
  }
}
