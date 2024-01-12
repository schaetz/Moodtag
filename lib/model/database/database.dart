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
}

class AssignedTags extends Table {
  IntColumn get artist => integer().references(Artists, #id)();
  IntColumn get tag => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {artist, tag};
}

class LastFmAccounts extends Table {
  TextColumn get accountName => text().unique().withLength(min: 1, max: 255)();
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
