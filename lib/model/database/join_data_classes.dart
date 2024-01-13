import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

abstract class DataClassWithEntityName extends NamedEntity {
  String get name;
  String get orderingName;
}

class ArtistData implements DataClassWithEntityName {
  ArtistData(this.artist, this.tags);

  final Artist artist;
  final Set<Tag> tags;

  bool hasTag(Tag tag) => tags.contains(tag);

  @override
  String get name => artist.name;

  @override
  String get orderingName => artist.orderingName;
}

typedef ArtistsList = List<ArtistData>;

class TagData implements DataClassWithEntityName {
  TagData(this.tag, this.freq);

  final Tag tag;
  final int? freq;

  @override
  String get name => tag.name;

  @override
  String get orderingName => tag.name.toLowerCase();
}

typedef TagsList = List<TagData>;

typedef TagCategoriesList = List<TagCategory>;
