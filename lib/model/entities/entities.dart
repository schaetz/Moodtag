import 'package:moodtag/shared/models/structs/named_entity.dart';

abstract class LibraryEntity implements NamedEntity {
  final String _name;

  const LibraryEntity({required name}) : _name = name;

  @override
  String get name => _name;
}

abstract class LibraryEntityWithId extends LibraryEntity {
  final int id;

  const LibraryEntityWithId({required super.name, required this.id});
}

extension EntityLookupExtension<T extends LibraryEntityWithId> on Iterable<T> {
  bool containsEntity(T lookupEntity) => this.any((element) => element.id == lookupEntity.id);
}

///
///
///

// BaseArtist only contains the properties from the "artists" table, without any joins
class BaseArtist extends LibraryEntityWithId with OrderingName {
  final String _orderingName;
  final String? spotifyId;

  const BaseArtist({required super.id, required super.name, required orderingName, this.spotifyId})
      : _orderingName = orderingName;

  @override
  String get orderingName => _orderingName;
}

class Artist extends BaseArtist {
  final Set<BaseTag> tags;

  const Artist(
      {required super.id, required super.name, required super.orderingName, super.spotifyId, required this.tags});

  bool hasTag(BaseTag tag) => tags.contains(tag);
}

// BaseTag only contains the properties from the "tags" table, without any joins
class BaseTag extends LibraryEntityWithId with OrderingName {
  final Tag? parentTag;
  final int colorMode;
  final int? color;

  const BaseTag({required super.id, required super.name, this.parentTag, required this.colorMode, this.color});

  @override
  String get orderingName => name;
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

class TagCategory extends LibraryEntityWithId with OrderingName {
  final int color;

  const TagCategory({required super.id, required super.name, required this.color});

  @override
  String get orderingName => name;
}

class LastFmAccount extends LibraryEntity {
  final String? realName;
  final int? playCount;
  final int? artistCount;
  final int? trackCount;
  final int? albumCount;
  final DateTime lastAccountUpdate;
  final DateTime lastTopArtistsUpdate;
  const LastFmAccount(
      {required super.name,
      this.realName,
      this.playCount,
      this.artistCount,
      this.trackCount,
      this.albumCount,
      required this.lastAccountUpdate,
      required this.lastTopArtistsUpdate});
}

enum PlayCountSource { LAST_FM, SPOTIFY, OTHER }

typedef ArtistsList = List<Artist>;
typedef TagsList = List<Tag>;
typedef TagCategoriesList = List<TagCategory>;
