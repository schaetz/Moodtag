import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_auth_bloc.dart';
import 'package:moodtag/features/import/spotify_import/connectors/spotify_connector.dart';
import 'package:moodtag/model/events/spotify_events.dart';

// Webview that displays the Spotify authorization page in a WebviewScaffold;
// after a successful login, the obtained authorization code and access token
// are stored in SpotifyAuthBloc, which then redirects to the screen that requires
// the Spotify authorization
class SpotifyLoginWebview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyAuthBloc>();
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((url) => bloc.add(LoginWebviewUrlChange(url)));

    return WebviewScaffold(
        url: getSpotifyAuthUri().toString(),
        appBar: MtAppBar(context),
        withZoom: true,
        withLocalStorage: true,
        hidden: false,
        initialChild: Container(
          color: Colors.redAccent,
          child: const Center(
            child: Text('Waiting.....'),
          ),
        ));
  }
}
