import 'dart:collection';
import 'package:flutter/cupertino.dart';

import 'artist.dart';

/*
 * Main model of the app containing all artists with their properties
 */
class Library extends ChangeNotifier {

  List<Artist> _artists = [];

  UnmodifiableListView<Artist> get artists => UnmodifiableListView(_artists);

  void add(Artist artist) {
    _artists.add(artist);
    notifyListeners();
  }

  void remove(Artist artist) {
    _artists.remove(artist);
    notifyListeners();
  }

  Library(this._artists);

}