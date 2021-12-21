import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/utils/spotify_import.dart';

class SpotifyLoginWebview extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((url) => _handleUrlChange(url, context));

    return WebviewScaffold(
      url: getSpotifyAuthUri().toString(),
      appBar: MtAppBar(context),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        color: Colors.redAccent,
        child: const Center(
          child: Text('Waiting.....'),
        ),
      )
    );
  }

  void _handleUrlChange(String url, BuildContext context) {
    Uri uri = Uri.parse(url);
    print(uri.authority);
    print(uri.queryParameters);
    if (isRedirectUri(uri)) {
      if (uri.queryParameters.containsKey('code')) {
        print('Obtained access token from Spotify: ${uri.queryParameters['code']}');
      }
      Navigator.of(context).pop();
    }
  }

}
