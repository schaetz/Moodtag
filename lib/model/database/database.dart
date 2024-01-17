import 'package:drift/drift.dart';

class Artists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 1, max: 255)();
  TextColumn get orderingName => text().withLength(min: 1, max: 255)();
  TextColumn get spotifyId => text().withLength(max: 255).nullable()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 1, max: 255)();
  IntColumn get category => integer().references(TagCategories, #id)();
  IntColumn get parentTag => integer().nullable().references(Tags, #id)();
  IntColumn get colorMode => integer().withDefault(const Constant(0))();
  IntColumn get color => integer().nullable()();
}

class AssignedTags extends Table {
  IntColumn get artist => integer().references(Artists, #id)();
  IntColumn get tag => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {artist, tag};
}

@DataClassName('TagCategory')
class TagCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 1, max: 255)();
  IntColumn get color => integer()();
}

class LastFmAccounts extends Table {
  TextColumn get accountName => text().withLength(min: 1, max: 255)();
  TextColumn get realName => text().withLength(max: 255).nullable()();
  IntColumn get playCount => integer().nullable()();
  IntColumn get artistCount => integer().nullable()();
  IntColumn get trackCount => integer().nullable()();
  IntColumn get albumCount => integer().nullable()();
  DateTimeColumn get lastAccountUpdate => dateTime()();
  DateTimeColumn get lastTopArtistsUpdate => dateTime()();

  @override
  Set<Column> get primaryKey => {accountName};
}
