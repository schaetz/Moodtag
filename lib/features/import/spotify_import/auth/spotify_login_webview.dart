import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_auth_bloc.dart';
import 'package:moodtag/features/import/spotify_import/connectors/spotify_connector.dart';
import 'package:moodtag/shared/bloc/events/spotify_events.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Webview that displays the Spotify authorization page in a WebviewScaffold;
// after a successful login, the obtained authorization code and access token
// are stored in SpotifyAuthBloc, which then redirects to the screen that requires
// the Spotify authorization
class SpotifyLoginWebview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SpotifyAuthBloc>();

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));

    return Scaffold(
        appBar: MtAppBar(context),
        body: WebViewWidget(controller: controller));
  }
}
