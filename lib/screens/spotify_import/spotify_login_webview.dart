import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/events/spotify_events.dart';
import 'package:moodtag/screens/spotify_import/spotify_connector.dart';

// Webview that displays the Spotify login page in a WebviewScaffold
// and returns the obtained access token to the import screen on successful login
class SpotifyLoginWebview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyImportBloc>();
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
