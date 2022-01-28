import 'package:flutter/material.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/exceptions/spotify_import_exception.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/structs/import_artists_arguments.dart';
import 'package:moodtag/utils/spotify_import.dart';

class SpotifyImportScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context),
      body: Center(
        child: TextButton(
          onPressed: () => _conductSpotifyImport(context),
          child: const Text('Start Spotify Import')
        ),
      )
    );
  }

}

void _conductSpotifyImport(context) {
  try {
    final authCodeFuture = Navigator.of(context).pushNamed(Routes.webView);
    authCodeFuture.then((authorizationCode) async {
      if (authorizationCode == null) {
        throw SpotifyImportException('Authorization in Spotify failed.');
      } else {
        print('Obtained authorization code from Spotify: $authorizationCode');
        final accessTokenResponseBodyJSON = await getAccessToken(authorizationCode);

        final accessToken = accessTokenResponseBodyJSON['access_token'];
        print('Obtained access token from Spotify: $accessToken');

        final followedArtists = await getFollowedArtists(accessToken);
        print(followedArtists);

        if (followedArtists.length == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No followed artists found."))
          );
        } else {
          Navigator.of(context).pushNamed(Routes.importArtistsList, arguments: new ImportArtistsArguments(followedArtists));
        }
      }
    });
  } catch (e) {
    print("Spotify import failed: $e");
    // TODO Add proper error handling
  }
}

