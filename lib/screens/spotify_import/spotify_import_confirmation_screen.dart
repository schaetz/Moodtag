import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/spotify_events.dart';

class SpotifyImportConfirmationScreen extends StatelessWidget {
  // TODO Use common property with list screens?
  static const headlineStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  final GlobalKey _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyImportBloc>();
    return Scaffold(
        key: _scaffoldKey,
        appBar: MtAppBar(context),
        body: Center(child: BlocBuilder<SpotifyImportBloc, SpotifyImportState>(builder: (context, state) {
          final entityFrequencies = _getEntityFrequencies(state);
          return Column(children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
                  child: Text('Confirm import:', style: headlineStyle),
                )),
            Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, _) => Divider(),
                    padding: EdgeInsets.all(16.0),
                    itemCount: entityFrequencies.length,
                    itemBuilder: (context, i) => ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  entityFrequencies.keys.elementAt(i),
                                  style: listEntryStyle,
                                ),
                              ),
                              Text(
                                entityFrequencies.values.elementAt(i).toString(),
                                style: listEntryStyle,
                              ),
                            ],
                          ),
                        )))
          ]);
        })),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (bloc.state.selectedArtists != null && bloc.state.selectedGenres != null) {
              bloc.add(CompleteSpotifyImport(bloc.state.selectedArtists!, bloc.state.selectedGenres!));
            } else {
              bloc.errorStreamController.add(UnknownError('Something went wrong.'));
            }
          },
          label: Text('Import'),
          icon: const Icon(Icons.library_add),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ));
  }

  Map<String, int> _getEntityFrequencies(SpotifyImportState state) {
    final Map<String, int> entityFreq = {};
    if (state.selectedArtists != null && state.selectedArtists!.isNotEmpty) {
      entityFreq.putIfAbsent('Artists', () => state.selectedArtists!.length);
    }
    if (state.selectedGenres != null && state.selectedGenres!.isNotEmpty) {
      entityFreq.putIfAbsent('Genres', () => state.selectedGenres!.length);
    }
    return entityFreq;
  }
}
