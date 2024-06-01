import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

abstract class LibraryEntity extends Equatable implements NamedEntity {
  final String _name;

  const LibraryEntity({required name}) : _name = name;

  @override
  String get name => _name;
}

abstract class LibraryEntityWithId extends LibraryEntity {
  final int id;

  const LibraryEntityWithId({required super.name, required this.id});
}

///
///
///

// BaseArtist only contains the properties from the "artists" table, without any joins
class BaseArtist extends LibraryEntityWithId with OrderingName {
  static const _equality = DeepCollectionEquality();

  final String _orderingName;
  final String? spotifyId;

  const BaseArtist({required super.id, required super.name, required orderingName, this.spotifyId})
      : _orderingName = orderingName;

  @override
  String get orderingName => _orderingName;

  @override
  List<Object?> get props => [id];

  // We need to manually override the == operator and hashCode method
  // because the Equatable package does not support treating derived classes as equal
  @override
  bool operator ==(Object other) => other is BaseArtist && _equality.equals(props, other.props);

  @override
  int get hashCode => id.hashCode;
}

class Artist extends BaseArtist {
  final Set<BaseTag> tags;

  const Artist(
      {required super.id, required super.name, required super.orderingName, super.spotifyId, required this.tags});

  bool hasTag(BaseTag tag) => tags.contains(tag);

  @override
  List<Object?> get props => [id];
}

// BaseTag only contains the properties from the "tags" table, without any joins
class BaseTag extends LibraryEntityWithId with OrderingName {
  static const _equality = DeepCollectionEquality();

  final Tag? parentTag;
  final int colorMode;
  final int? color;

  const BaseTag({required super.id, required super.name, this.parentTag, required this.colorMode, this.color});

  @override
  String get orderingName => name;

  @override
  List<Object?> get props => [id];

  // We need to manually override the == operator and hashCode method
  // because the Equatable package does not support treating derived classes as equal
  @override
  bool operator ==(Object other) => other is BaseTag && _equality.equals(props, other.props);

  @override
  int get hashCode => id.hashCode;
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

  @override
  List<Object?> get props => [id];
}

class TagCategory extends LibraryEntityWithId with OrderingName {
  final int color;

  const TagCategory({required super.id, required super.name, required this.color});

  @override
  String get orderingName => name;

  @override
  List<Object?> get props => [id];
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

  @override
  List<Object?> get props => [name];
}

typedef ArtistsList = List<Artist>;
typedef TagsList = List<Tag>;
typedef TagCategoriesList = List<TagCategory>;
