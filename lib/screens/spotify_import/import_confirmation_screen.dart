import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_state.dart';
import 'package:moodtag/model/events/spotify_events.dart';

class ImportConfirmationScreen extends StatelessWidget {
  // TODO Use common property with list screens?
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  final GlobalKey _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyImportBloc>();
    return Scaffold(
        key: _scaffoldKey,
        appBar: MtAppBar(context),
        body: Center(
          child: Column(
            children: [
              BlocBuilder<SpotifyImportBloc, SpotifyImportState>(builder: (context, state) {
                final entityFrequencies = _getEntityFrequencies(state);
                return ListView.separated(
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
                        ));
              })
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => bloc.add(CompleteSpotifyImport()),
          child: const Icon(Icons.library_add),
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
