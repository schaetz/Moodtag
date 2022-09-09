import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/blocs/artist_details/artist_details_cubit.dart';
import 'package:moodtag/model/blocs/tag_details/tag_details_cubit.dart';
import 'package:moodtag/screens/artist_details_screen.dart';
import 'package:moodtag/screens/artists_list_screen.dart';
import 'package:moodtag/screens/lastfm_import/lastfm_import_screen.dart';
import 'package:moodtag/screens/spotify_import/import_flow.dart';
import 'package:moodtag/screens/tag_details_screen.dart';
import 'package:moodtag/screens/tags_list_screen.dart';

class Routes {
  static const artistsList = '/artists';
  static const artistsDetails = '/artists/details';
  static const tagsList = '/tags';
  static const tagsDetails = '/tags/details';
  static const lastFmImport = '/lastFmImport';
  static const spotifyImport = '/spotifyImport';
  static const importArtistsList = '/importArtists';
  static const importGenresList = '/importGenres';
  static const webView = '/webView';

  static const initialRoute = artistsList;

  static Routes _instance;

  static Routes instance() {
    if (_instance == null) {
      _instance = new Routes();
    }
    return _instance;
  }

  Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      artistsList: (context) => ArtistsListScreen(),
      tagsList: (context) => TagsListScreen(),
      artistsDetails: (context) => BlocProvider(
          create: (_) => ArtistDetailsCubit(artistId: ModalRoute.of(context).settings.arguments as int)..initialize(),
          child: const ArtistDetailsScreen()),
      tagsDetails: (context) => BlocProvider(
          create: (_) => TagDetailsCubit(tagId: ModalRoute.of(context).settings.arguments as int)..initialize(),
          child: const TagDetailsScreen()),
      lastFmImport: (context) => LastfmImportScreen(),
      spotifyImport: (context) => ImportFlow(),
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
