import 'package:flutter/material.dart';

import 'package:moodtag/screens/artist_details.dart';
import 'package:moodtag/screens/artists_list.dart';
import 'package:moodtag/screens/tag_details.dart';
import 'package:moodtag/screens/tags_list.dart';

class Routes {

  static const artistsList = '/artists';
  static const artistsDetails = '/artists/details';
  static const tagsList = '/tags';
  static const tagsDetails = '/tags/details';

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
    };
  }

}