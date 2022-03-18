import 'package:flutter/material.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/exceptions/spotify_import_exception.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/structs/imported_artist.dart';
import 'package:moodtag/structs/unique_named_entity_set.dart';
import 'package:moodtag/utils/spotify_import.dart';

class SpotifyImportScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SpotifyImportScreenState();

}

class _SpotifyImportScreenState extends State<SpotifyImportScreen> {

  bool _useTopArtists = true;
  bool _useFollowedArtists = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context),
      body: Center(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
                child: Text('Select what should be imported:'),
              )
            ),
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
            TextButton(
              onPressed: _buttonEnabled ? () => _conductSpotifyImport(context, _useTopArtists, _useFollowedArtists) : null,
              child: const Text('Start Spotify Import'),
            ),
          ],
        ),
      )
    );
  }

  bool get _buttonEnabled => _useTopArtists || _useFollowedArtists;

}

void _conductSpotifyImport(BuildContext context, bool useTopArtists, bool useFollowedArtists) {
  final authCodeFuture = Navigator.of(context).pushNamed(Routes.webView);
  authCodeFuture.then((authorizationCode) async {
    if (authorizationCode == null) {
      throw SpotifyImportException('Authorization in Spotify failed.');
    } else {
      try {
        print('Obtained authorization code from Spotify: $authorizationCode');
        final accessTokenResponseBodyJSON = await getAccessToken(authorizationCode);

        final accessToken = accessTokenResponseBodyJSON['access_token'];
        print('Obtained access token from Spotify: $accessToken');

        final importedArtists = UniqueNamedEntitySet<ImportedArtist>();

        if (useTopArtists) {
          importedArtists.addAll(await getTopArtists(accessToken, 50, 0));
        }
        if (useFollowedArtists) {
          importedArtists.addAll(await getFollowedArtists(accessToken));
        }

        if (importedArtists.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No artists to import."))
          );
        } else {
          Navigator.of(context).pushNamed(Routes.importArtistsList, arguments: importedArtists);
        }
      } catch (e) {
        print("Spotify import failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Spotify import failed."))
        );
      }
    }
  });
}

