import 'dart:collection';

import 'album.dart';
import 'package:moodtag/models/tag.dart';
import 'package:moodtag/utils/helpers.dart';
import 'package:flutter/widgets.dart';

class Artist extends ChangeNotifier {

  static const denotationSingular = 'artist';
  static const denotationPlural = 'artists';

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
  Artist.withTags(this.name, final List<Tag> tags) : _tags = List.from(tags);

  void addTag(Tag tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void removeTag(Tag tag) {
    _tags.remove(tag);
    notifyListeners();
  }

}