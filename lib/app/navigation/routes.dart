import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/app_settings/app_settings_bloc.dart';
import 'package:moodtag/features/app_settings/app_settings_screen.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_bloc.dart';
import 'package:moodtag/features/import/lastfm_import/flow/lastfm_import_flow.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_auth_bloc.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_login_webview.dart';
import 'package:moodtag/features/import/spotify_import/bloc/spotify_import_bloc.dart';
import 'package:moodtag/features/import/spotify_import/flow/spotify_import_flow.dart';
import 'package:moodtag/features/library/details_screens/artist_details/artist_details_bloc.dart';
import 'package:moodtag/features/library/details_screens/artist_details/artist_details_screen.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_bloc.dart';
import 'package:moodtag/features/library/details_screens/tag_details/tag_details_screen.dart';
import 'package:moodtag/features/library/main_screen/artists_list/artists_list_bloc.dart';
import 'package:moodtag/features/library/main_screen/library_main_screen.dart';
import 'package:moodtag/features/library/main_screen/tags_list/tags_list_bloc.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/bloc/events/import_events.dart';

class Routes {
  static const libraryMainScreen = '/library';
  static const artistsDetails = '/artists/details';
  static const tagsDetails = '/tags/details';
  static const appSettings = '/appSettings';
  static const lastFmImport = '/lastFmImport';
  static const spotifyAuth = '/spotifyAuth';
  static const spotifyImport = '/spotifyImport';
  static const importArtistsList = '/importArtists';
  static const importGenresList = '/importGenres';
  static const webView = '/webView';

  static const initialRoute = libraryMainScreen;

  static Routes? _instance;

  static Routes instance() {
    if (_instance == null) {
      _instance = new Routes();
    }
    return _instance!;
  }

  Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      libraryMainScreen: (context) => MultiBlocProvider(providers: [
            BlocProvider(
              create: (_) => ArtistsListBloc(context.read<Repository>(), context),
            ),
            BlocProvider(
              create: (_) => TagsListBloc(context.read<Repository>(), context),
            ),
          ], child: LibraryMainScreen()),
      artistsDetails: (context) => BlocProvider(
          create: (_) => ArtistDetailsBloc(context.read<Repository>(), context,
              ModalRoute.of(context)?.settings.arguments as int, context.read<SpotifyAuthBloc>()),
          child: ArtistDetailsScreen()),
      tagsDetails: (context) => BlocProvider(
          create: (_) =>
              TagDetailsBloc(context.read<Repository>(), context, ModalRoute.of(context)?.settings.arguments as int),
          child: TagDetailsScreen()),
      appSettings: (context) =>
          BlocProvider(create: (_) => AppSettingsBloc(context.read<Repository>(), context), child: AppSettingsScreen()),
      lastFmImport: (context) => BlocProvider(
          create: (_) => LastFmImportBloc(context.read<Repository>(), context)..add(InitializeImport()),
          child: LastFmImportFlow()),
      spotifyAuth: (context) => SpotifyLoginWebview(),
      spotifyImport: (context) => BlocProvider(
          create: (_) => SpotifyImportBloc(context.read<Repository>(), context, context.read<SpotifyAuthBloc>())
            ..add(InitializeImport()),
          child: SpotifyImportFlow()),
    };
  }
}

extension ModalRouteExt on ModalRoute {
  static RoutePredicate withName(String name) {
    return (Route<dynamic> route) {
      return !route.willHandlePopInternally && route is ModalRoute && route.settings.name == name;
    };
  }

  static RoutePredicate withNames(String name1, String name2) {
    return (Route<dynamic> route) {
      return !route.willHandlePopInternally &&
          route is ModalRoute &&
          (route.settings.name == name1 || route.settings.name == name2);
    };
  }
}
