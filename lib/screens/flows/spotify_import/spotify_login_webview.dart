import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/utils/spotify_connector.dart';

import 'import_flow_state.dart';

// Webview that displays the Spotify login page in a WebviewScaffold
// and returns the obtained access token to the import screen on successful login
class SpotifyLoginWebview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((url) => _handleUrlChange(url, context));

    return WebviewScaffold(
        url: getSpotifyAuthUri().toString(),
        appBar: MtAppBar(context, forceBackButton: true),
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(
          color: Colors.redAccent,
          child: const Center(
            child: Text('Waiting.....'),
          ),
        ));
  }

  void _handleUrlChange(String url, BuildContext context) {
    Uri uri = Uri.parse(url);
    print(uri.authority);
    print(uri.queryParameters);
    print('uri: ' + uri.toString());
    if (isRedirectUri(uri)) {
      final authorizationCode = uri.queryParameters.containsKey('code') ? uri.queryParameters['code'] : null;
      context.flow<ImportFlowState>().update((state) => state.copyWith(spotifyAuthCode: authorizationCode));
    }
  }
}
