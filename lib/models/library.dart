import 'dart:collection';

import 'artist.dart';
import 'package:moodtag/exceptions/invalid_argument_exception.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/models/tag.dart';
import 'package:moodtag/utils/helpers.dart';
import 'package:flutter/widgets.dart';

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

  List<Artist> getArtistsWithTag(Tag tag) {
    List<Artist> artistsWithTag = _artists.where((artist) => artist.tags.contains(tag)).toList();
    artistsWithTag.sortArtistNames();
    return artistsWithTag;
  }

  Artist getArtistByName(String artistName) {
    var artistsWithName = _artists.where((artist) => artist.name == artistName);
    if (artistsWithName.isNotEmpty) {
      return artistsWithName.first;
    } else {
      throw InvalidArgumentException();
    }
  }

  Artist createArtist(String artistName, [List<Tag> tags]) {
    if (_doesArtistNameAlreadyExist(artistName)) {
      throw NameAlreadyTakenException('There is already an artist with the name "' + artistName + '".');
    } else {
      tags ??= [];
      Artist newArtist = Artist.withTags(artistName, tags);
      _addArtist(newArtist);
      return newArtist;
    }
  }

  Tag createTag(String tagName) {
    if (_doesTagNameAlreadyExist(tagName)) {
      throw NameAlreadyTakenException('There is already a tag with the name "' + tagName + '".');
    } else {
      Tag newTag = Tag(tagName);
      _addTag(newTag);
      return newTag;
    }
  }

  void deleteArtist(Artist artist) {
    _removeArtist(artist);
  }

  void deleteTag(Tag tag) {
    for (Artist artist in getArtistsWithTag(tag)) {
      artist.removeTag(tag);
    }
    _removeTag(tag);
  }

  bool _doesArtistNameAlreadyExist(String artistName) {
    return _artists.where((artist) => artist.name == artistName).isNotEmpty;
  }

  bool _doesTagNameAlreadyExist(String tagName) {
    return _tags.where((tag) => tag.name == tagName).isNotEmpty;
  }

  void _addArtist(Artist artist) {
    _artists.add(artist);
    _addChangeListenerToNewArtist(artist);
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

  Library(artists, tags) {
    // Copy the values into new data structures,
    // otherwise sample artists will always have the same set of tags
    this._artists = List.from(artists);
    this._artists.forEach((artist) => _addChangeListenerToNewArtist(artist));
    this._tags = List.from(tags);
  }

  _addChangeListenerToNewArtist(Artist artist) {
    artist.addListener(() => this.notifyListeners());
  }

}