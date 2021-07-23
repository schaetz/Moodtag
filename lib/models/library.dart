import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:moodtag/models/tag.dart';

import 'artist.dart';
import 'package:moodtag/helpers.dart';

/*
 * Main model of the app containing all artists with their properties
 */
class Library extends ChangeNotifier {

  List<Artist> _artists = [];
  List<Tag> _tags = [];

  UnmodifiableListView<Artist> get artists {
    List<Artist> artistsSorted = List.from(_artists);
    artistsSorted.sortArtistNames();
    return UnmodifiableListView(artistsSorted);
  }

  UnmodifiableListView<Tag> get tags {
    List<Tag> tagsSorted = List.from(_tags);
    tagsSorted.sortTags();
    return UnmodifiableListView(tagsSorted);
  }

  List<Artist> getArtistsWithTag(Tag tag) =>
      _artists.where((artist) => artist.tags.contains(tag)).toList();

  void addArtist(Artist artist) {
    _artists.add(artist);
    notifyListeners();
  }

  void removeArtist(Artist artist) {
    _artists.remove(artist);
    notifyListeners();
  }

  void addTag(Tag tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void removeTag(Tag tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  Library(this._artists, this._tags);

}