import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/components/import_config_form.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/screens/flows/spotify_import/import_options.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/spotify_connector.dart';

import 'import_flow_state.dart';

class SpotifyImportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpotifyImportScreenState();
}

class _SpotifyImportScreenState extends State<SpotifyImportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context, forceBackButton: true),
      body: Center(
          child: ImportConfigForm(
        headlineCaption: 'Select what should be imported:',
        sendButtonCaption: 'Start Spotify Import',
        configItemsWithCaption: {
          IMPORT_OPTION_TOP_ARTISTS: 'Top artists',
          IMPORT_OPTION_FOLLOWED_ARTISTS: 'Followed artists',
          IMPORT_OPTION_ARTIST_GENRES: 'Artist genres'
        },
        onSend: _conductSpotifyImport,
      )),
    );
  }
}

void _conductSpotifyImport(BuildContext context, Map<String, bool> selections) async {
  try {
    final authorizationCode = context.flow<ImportFlowState>().state.spotifyAuthCode;

    print('Obtained authorization code from Spotify: $authorizationCode');
    final accessTokenResponseBodyJSON = await getAccessToken(authorizationCode);

    final accessToken = accessTokenResponseBodyJSON['access_token'];
    print('Obtained access token from Spotify: $accessToken');

    final availableSpotifyArtists = UniqueNamedEntitySet<ImportedArtist>();

    if (selections[IMPORT_OPTION_TOP_ARTISTS]) {
      availableSpotifyArtists.addAll(await getTopArtists(accessToken, 50, 0));
    }
    if (selections[IMPORT_OPTION_FOLLOWED_ARTISTS]) {
      availableSpotifyArtists.addAll(await getFollowedArtists(accessToken));
    }

    if (availableSpotifyArtists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No artists to import.")));
    } else {
      context.flow<ImportFlowState>().update((state) => state.copyWith(
          availableSpotifyArtists: availableSpotifyArtists, doImportGenres: selections[IMPORT_OPTION_ARTIST_GENRES]));
    }
  } catch (e) {
    print("Spotify import failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Spotify import failed.")));
  }
}
