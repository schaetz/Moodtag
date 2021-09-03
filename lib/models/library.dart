import 'dart:collection';
import 'package:flutter/cupertino.dart';

import 'artist.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/models/tag.dart';
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

  void createArtist(String artistName) {
    if (_doesArtistNameAlreadyExist(artistName)) {
      throw NameAlreadyTakenException('There is already an artist with the name "' + artistName + '".');
    } else {
      _addArtist(Artist(artistName));
    }
  }

  bool _doesArtistNameAlreadyExist(String artistName) {
    return _artists.where((artist) => artist.name == artistName).isNotEmpty;
  }

  void _addArtist(Artist artist) {
    _artists.add(artist);
    notifyListeners();
  }

  void _removeArtist(Artist artist) {
    _artists.remove(artist);
    notifyListeners();
  }

  void _addTag(Tag tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void _removeTag(Tag tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  Library(this._artists, this._tags);

}