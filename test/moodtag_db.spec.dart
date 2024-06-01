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
    final artist = await db!.getBaseArtistByIdOnce(artistId);

    expect(artist?.name, 'AC/DC');
  });

  test('tags can be created', () async {
    final tagId = await db!.createTag(TagsCompanion(id: Value(123), name: Value('Rock'), category: Value(1)));
    final tag = await db!.getTagByIdOnce(tagId);

    expect(tag?.name, 'Rock');
  });

  test('tags can be assigned to artists', () async {
    final artistId =
        await db!.createArtist(ArtistsCompanion(id: Value(123), name: Value('AC/DC'), orderingName: Value('AC/DC')));

    final tag1Id = await db!.createTag(TagsCompanion(id: Value(123), name: Value('Rock'), category: Value(1)));
    final tag1 = await db!.getTagByIdOnce(tag1Id);
    final tag2Id = await db!.createTag(TagsCompanion(id: Value(456), name: Value('Pop'), category: Value(1)));
    final tag2 = await db!.getTagByIdOnce(tag2Id);

    await db!.assignTagToArtist(AssignedTagsCompanion(artist: Value(artistId), tag: Value(tag1Id)));

    final artistWithTagsDto = await db!.getArtistById(artistId).first;
    expect(artistWithTagsDto?.tags.contains(tag1!), true);
    expect(artistWithTagsDto?.tags.contains(tag2!), false);
  });

  test('artists can be joined with their tags to return Artist objects', () async {
    final artist1Id =
        await db!.createArtist(ArtistsCompanion(id: Value(123), name: Value('AC/DC'), orderingName: Value('AC/DC')));
    final artist2Id =
        await db!.createArtist(ArtistsCompanion(id: Value(456), name: Value('Queen'), orderingName: Value('Queen')));

    final artists = await db!.getArtists({}).first;
    expect(artists.length, 2);

    // Assign a tag and filter by it
    final tag1Id = await db!.createTag(TagsCompanion(id: Value(123), name: Value('Rock'), category: Value(1)));
    final tag1 = await db!.getTagByIdOnce(tag1Id);

    await db!.assignTagToArtist(AssignedTagsCompanion(artist: Value(artist1Id), tag: Value(tag1Id)));
    await db!.assignTagToArtist(AssignedTagsCompanion(artist: Value(artist2Id), tag: Value(tag1Id)));

    final artistsWithTag = await db!.getArtists({tag1!.id}).first;
    expect(artistsWithTag.length, 2);

    // Filtering by a unassigned tag should return an empty list
    final tag2Id = await db!.createTag(TagsCompanion(id: Value(456), name: Value('Pop'), category: Value(1)));
    final tag2 = await db!.getTagByIdOnce(tag2Id);

    final artistsWithOtherTag = await db!.getArtists({tag2!.id}).first;
    expect(artistsWithOtherTag.length, 0);
  });
}
