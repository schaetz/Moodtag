import 'dart:collection';

import 'album.dart';
import 'package:moodtag/helpers.dart';
import 'package:moodtag/models/tag.dart';

class Artist {

  String name;
  final List<Album> _albums = [];
  final List<Tag> _tags;

  UnmodifiableListView<Album> get albums => UnmodifiableListView(_albums);

  UnmodifiableListView<Tag> get tags {
    List<Tag> tagsSorted = List.from(_tags);
    tagsSorted.sortTags();
    return UnmodifiableListView(tagsSorted);
  }

  Artist(this.name) : this._tags = [];
  Artist.withTags(this.name, this._tags);

}