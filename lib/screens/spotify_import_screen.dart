import 'package:flutter/material.dart';
import 'package:moodtag/components/mt_app_bar.dart';

class SpotifyImportScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context),
      body: Center(
        child: TextButton(
          onPressed: () => _conductSpotifyImport(),
          child: const Text('Start Spotify Import')
        ),
      )
    );
  }

}

void _conductSpotifyImport() {
  throw UnimplementedError(); // TODO
}

