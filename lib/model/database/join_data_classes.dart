import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

abstract class DataClassWithEntityName extends NamedEntity {
  String get name;
  String get orderingName;
}

class ArtistData implements DataClassWithEntityName {
  final Artist artist;
  final Set<Tag> tags;

  ArtistData(this.artist, this.tags);

  bool hasTag(Tag tag) => tags.contains(tag);

  @override
  String get name => artist.name;

  @override
  String get orderingName => artist.orderingName;
}

typedef ArtistsList = List<ArtistData>;

class TagData implements DataClassWithEntityName {
  final Tag tag;
  final TagCategory category;
  final int? freq;

  TagData(this.tag, this.category, this.freq);

  @override
  String get name => tag.name;

  @override
  String get orderingName => tag.name.toLowerCase();
}

typedef TagsList = List<TagData>;

class TagCategoryData implements DataClassWithEntityName {
  final TagCategory tagCategory;

  TagCategoryData(this.tagCategory);

  @override
  String get name => tagCategory.name;

  @override
  String get orderingName => tagCategory.name.toLowerCase();
}

typedef TagCategoriesList = List<TagCategoryData>;
