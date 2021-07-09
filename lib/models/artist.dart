import 'dart:collection';

import 'album.dart';
import 'package:moodtag/models/tag.dart';

class Artist {

  String name;
  final List<Album> _albums = [];
  final List<Tag> _tags = [];

  UnmodifiableListView<Album> get albums => UnmodifiableListView(_albums);
  UnmodifiableListView<Tag> get tags => UnmodifiableListView(_tags);

  Artist(this.name);

}