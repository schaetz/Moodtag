import 'package:flutter/material.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/navigation/routes.dart';

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
  Navigator.of(context).pushNamed(Routes.webView);
}

