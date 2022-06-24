import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/flows/import_flow_state.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/spotify_connector.dart';

class SpotifyImportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpotifyImportScreenState();
}

class _SpotifyImportScreenState extends State<SpotifyImportScreen> {
  bool _useTopArtists = true;
  bool _useFollowedArtists = true;
  bool _useArtistGenres = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MtAppBar(context, forceBackButton: true),
        body: Center(
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
                    child: Text('Select what should be imported:'),
                  )),
              CheckboxListTile(
                title: Text('Top artists'),
                value: _useTopArtists,
                onChanged: (newValue) {
                  setState(() {
                    _useTopArtists = newValue;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Followed artists'),
                value: _useFollowedArtists,
                onChanged: (newValue) {
                  setState(() {
                    _useFollowedArtists = newValue;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Artist genres'),
                value: _useArtistGenres,
                onChanged: (newValue) {
                  setState(() {
                    _useArtistGenres = newValue;
                  });
                },
              ),
              TextButton(
                onPressed: _buttonEnabled
                    ? () => _conductSpotifyImport(context, _useTopArtists, _useFollowedArtists, _useArtistGenres)
                    : null,
                child: const Text('Start Spotify Import'),
              ),
            ],
          ),
        ));
  }

  bool get _buttonEnabled => _useTopArtists || _useFollowedArtists;
}

void _conductSpotifyImport(
    BuildContext context, bool useTopArtists, bool useFollowedArtists, bool useArtistGenres) async {
  try {
    final authorizationCode = context.flow<ImportFlowState>().state.spotifyAuthCode;

    print('Obtained authorization code from Spotify: $authorizationCode');
    final accessTokenResponseBodyJSON = await getAccessToken(authorizationCode);

    final accessToken = accessTokenResponseBodyJSON['access_token'];
    print('Obtained access token from Spotify: $accessToken');

    final availableSpotifyArtists = UniqueNamedEntitySet<ImportedArtist>();

    if (useTopArtists) {
      availableSpotifyArtists.addAll(await getTopArtists(accessToken, 50, 0));
    }
    if (useFollowedArtists) {
      availableSpotifyArtists.addAll(await getFollowedArtists(accessToken));
    }

    if (availableSpotifyArtists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No artists to import.")));
    } else {
      context.flow<ImportFlowState>().update(
          (state) => state.copyWith(availableSpotifyArtists: availableSpotifyArtists, doImportGenres: useArtistGenres));
    }
  } catch (e) {
    print("Spotify import failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Spotify import failed.")));
  }
}