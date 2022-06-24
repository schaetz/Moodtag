import 'package:flutter/material.dart';
import 'package:moodtag/flows/import_flow.dart';
import 'package:moodtag/screens/artist_details.dart';
import 'package:moodtag/screens/artists_list.dart';
import 'package:moodtag/screens/lastfm_import.dart';
import 'package:moodtag/screens/tag_details.dart';
import 'package:moodtag/screens/tags_list.dart';

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
      artistsDetails: (context) => ArtistDetailsScreen(context),
      tagsDetails: (context) => TagDetailsScreen(context),
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
