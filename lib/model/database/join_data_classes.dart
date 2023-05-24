import 'package:moodtag/model/database/moodtag_db.dart';

abstract class DataClassWithEntityName {
  String get name;
}

class ArtistData implements DataClassWithEntityName {
  ArtistData(this.artist, this.tags);

  final Artist artist;
  final Set<Tag> tags;

  bool hasTag(Tag tag) => tags.contains(tag);

  @override
  String get name => artist.name;
}

typedef ArtistsList = List<ArtistData>;

class TagData implements DataClassWithEntityName {
  TagData(this.tag, this.freq);

  final Tag tag;
  final int? freq;

  @override
  String get name => tag.name;
}

typedef TagsList = List<TagData>;
