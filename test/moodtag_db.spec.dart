import 'package:drift/drift.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:test/test.dart';

void main() {
  MoodtagDB? db;

  setUp(() {
    db = MoodtagDB.InMemory();
  });

  tearDown(() async {
    await db!.close();
  });

  test('artists can be created', () async {
    final artistId =
        await db!.createArtist(ArtistsCompanion(id: Value(123), name: Value('AC/DC'), orderingName: Value('AC/DC')));
    final artist = await db!.getArtistByIdOnce(artistId);

    expect(artist?.name, 'AC/DC');
  });

  test('tags can be created', () async {
    final tagId = await db!.createTag(TagsCompanion(id: Value(123), name: Value('Rock')));
    final tag = await db!.getTagByIdOnce(tagId);

    expect(tag?.name, 'Rock');
  });

  test('tags can be assigned to artists', () async {
    final artistId =
        await db!.createArtist(ArtistsCompanion(id: Value(123), name: Value('AC/DC'), orderingName: Value('AC/DC')));

    final tag1Id = await db!.createTag(TagsCompanion(id: Value(123), name: Value('Rock')));
    final tag1 = await db!.getTagByIdOnce(tag1Id);
    final tag2Id = await db!.createTag(TagsCompanion(id: Value(456), name: Value('Pop')));
    final tag2 = await db!.getTagByIdOnce(tag2Id);

    // TODO This should not result in an infinite loop!
    // var artistDataBefore = await db!.getArtistsDataList({}).first;
    // expect(artistDataBefore?.hasTag(tag1!), false);

    await db!.assignTagToArtist(AssignedTagsCompanion(artist: Value(artistId), tag: Value(tag1Id)));

    final artistData = await db!.getArtistDataById(artistId).first;
    expect(artistData?.hasTag(tag1!), true);
    expect(artistData?.hasTag(tag2!), false);
  });

  test('artists can be joined with their tags to return ArtistData objects', () async {
    final artist1Id =
        await db!.createArtist(ArtistsCompanion(id: Value(123), name: Value('AC/DC'), orderingName: Value('AC/DC')));
    final artist2Id =
        await db!.createArtist(ArtistsCompanion(id: Value(456), name: Value('Queen'), orderingName: Value('Queen')));

    final artistsData = await db!.getArtistsDataList({}).first;
    expect(artistsData.length, 2);

    // Assign a tag and filter by it
    final tag1Id = await db!.createTag(TagsCompanion(id: Value(123), name: Value('Rock')));
    final tag1 = await db!.getTagByIdOnce(tag1Id);

    await db!.assignTagToArtist(AssignedTagsCompanion(artist: Value(artist1Id), tag: Value(tag1Id)));
    await db!.assignTagToArtist(AssignedTagsCompanion(artist: Value(artist2Id), tag: Value(tag1Id)));

    final artistsDataWithTag = await db!.getArtistsDataList({tag1!}).first;
    expect(artistsDataWithTag.length, 2);

    // Filtering by a unassigned tag should return an empty list
    final tag2Id = await db!.createTag(TagsCompanion(id: Value(456), name: Value('Pop')));
    final tag2 = await db!.getTagByIdOnce(tag2Id);

    final artistsDataWithOtherTag = await db!.getArtistsDataList({tag2!}).first;
    expect(artistsDataWithOtherTag.length, 0);
  });
}
