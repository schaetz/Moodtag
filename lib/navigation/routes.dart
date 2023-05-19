import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/artist_details/artist_details_bloc.dart';
import 'package:moodtag/model/blocs/artists_list/artists_list_bloc.dart';
import 'package:moodtag/model/blocs/entity_loader/entity_loader_bloc.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_bloc.dart';
import 'package:moodtag/model/blocs/spotify_auth/spotify_auth_bloc.dart';
import 'package:moodtag/model/blocs/spotify_import/spotify_import_bloc.dart';
import 'package:moodtag/model/blocs/tag_details/tag_details_bloc.dart';
import 'package:moodtag/model/blocs/tags_list/tags_list_bloc.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/screens/lastfm_import/lastfm_import_screen.dart';
import 'package:moodtag/screens/library/artist_details_screen.dart';
import 'package:moodtag/screens/library/artists_list_screen.dart';
import 'package:moodtag/screens/library/tag_details_screen.dart';
import 'package:moodtag/screens/library/tags_list_screen.dart';
import 'package:moodtag/screens/spotify_import/import_flow.dart';
import 'package:moodtag/screens/spotify_import/spotify_login_webview.dart';

class Routes {
  static const artistsList = '/artists';
  static const artistsDetails = '/artists/details';
  static const tagsList = '/tags';
  static const tagsDetails = '/tags/details';
  static const lastFmImport = '/lastFmImport';
  static const spotifyAuth = '/spotifyAuth';
  static const spotifyImport = '/spotifyImport';
  static const importArtistsList = '/importArtists';
  static const importGenresList = '/importGenres';
  static const webView = '/webView';

  static const initialRoute = artistsList;

  static Routes? _instance;

  static Routes instance() {
    if (_instance == null) {
      _instance = new Routes();
    }
    return _instance!;
  }

  Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      artistsList: (context) =>
          BlocProvider(create: (_) => ArtistsListBloc(context.read<Repository>(), context), child: ArtistsListScreen()),
      tagsList: (context) => BlocProvider(
          create: (_) => TagsListBloc(context.read<Repository>(), context, context.read<EntityLoaderBloc>()),
          child: TagsListScreen()),
      artistsDetails: (context) => BlocProvider(
          create: (_) =>
              ArtistDetailsBloc(context.read<Repository>(), context, ModalRoute.of(context)?.settings.arguments as int),
          child: ArtistDetailsScreen()),
      tagsDetails: (context) => BlocProvider(
          create: (_) =>
              TagDetailsBloc(context.read<Repository>(), context, ModalRoute.of(context)?.settings.arguments as int),
          child: TagDetailsScreen()),
      lastFmImport: (context) => BlocProvider(
          create: (_) => LastFmImportBloc(context.read<Repository>(), context), child: LastfmImportScreen()),
      spotifyAuth: (context) => SpotifyLoginWebview(),
      spotifyImport: (context) => BlocProvider(
          create: (_) => SpotifyImportBloc(context.read<Repository>(), context, context.read<SpotifyAuthBloc>()),
          child: ImportFlow()),
    };
  }
}

extension ModalRouteExt on ModalRoute {
  static RoutePredicate withNames(String name1, String name2) {
    return (Route<dynamic> route) {
      return !route.willHandlePopInternally &&
          route is ModalRoute &&
          (route.settings.name == name1 || route.settings.name == name2);
    };
  }
}
