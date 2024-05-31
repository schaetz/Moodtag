class BaseArtist {
  final int id;
  final String name;
  final String orderingName;
  final String? spotifyId;

  const BaseArtist({required this.id, required this.name, required this.orderingName, this.spotifyId});
}

class Artist extends BaseArtist {
  final Set<BaseTag> tags;

  const Artist(
      {required super.id, required super.name, required super.orderingName, required this.tags, super.spotifyId});
}

// BaseTag only contains the properties from the "tags" table, without any joins
class BaseTag {
  final int id;
  final String name;
  final Tag? parentTag;
  final int colorMode;
  final int? color;

  const BaseTag({required this.id, required this.name, this.parentTag, required this.colorMode, this.color});
}

class Tag extends BaseTag {
  final TagCategory category;
  final int frequency;

  const Tag(
      {required super.id,
      required super.name,
      super.parentTag,
      required super.colorMode,
      super.color,
      required this.category,
      required this.frequency});
}

class TagCategory {
  final int id;
  final String name;
  final int color;

  const TagCategory({required this.id, required this.name, required this.color});
}

class LastFmAccount {
  final String accountName;
  final String? realName;
  final int? playCount;
  final int? artistCount;
  final int? trackCount;
  final int? albumCount;
  final DateTime lastAccountUpdate;
  final DateTime lastTopArtistsUpdate;
  const LastFmAccount(
      {required this.accountName,
      this.realName,
      this.playCount,
      this.artistCount,
      this.trackCount,
      this.albumCount,
      required this.lastAccountUpdate,
      required this.lastTopArtistsUpdate});
}

typedef ArtistsList = List<BaseArtist>;
typedef TagsList = List<Tag>;
typedef TagCategoriesList = List<TagCategory>;
