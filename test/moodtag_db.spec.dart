import 'package:drift/drift.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:test/test.dart';

void main() {
  late final MoodtagDB db;

  setUpAll(() {
    db = MoodtagDB.InMemory();
  });

  tearDownAll(() async {
    await db.close();
  });

  test('artists can be created', () async {
    final artistId =
        await db.createArtist(ArtistsCompanion(id: Value(123), name: Value('AC/DC'), orderingName: Value('AC/DC')));
    final artist = await db.getArtistByIdOnce(artistId);

    expect(artist?.name, 'AC/DC');
  });

  test('tags can be created', () async {
    final tagId = await db.createTag(TagsCompanion(id: Value(123), name: Value('Rock')));
    final tag = await db.getTagByIdOnce(tagId);

    expect(tag?.name, 'Rock');
  });

  test('tags can be assigned to artists', () async {
    final artistId =
        await db.createArtist(ArtistsCompanion(id: Value(123), name: Value('AC/DC'), orderingName: Value('AC/DC')));

    final tag1Id = await db.createTag(TagsCompanion(id: Value(123), name: Value('Rock')));
    final tag1 = await db.getTagByIdOnce(tag1Id);
    final tag2Id = await db.createTag(TagsCompanion(id: Value(456), name: Value('Pop')));
    final tag2 = await db.getTagByIdOnce(tag2Id);

    // TODO This should not result in an infinite loop!
    // var artistDataBefore = await db.getArtistDataById(artistId).first;
    // expect(artistDataBefore?.hasTag(tag1!), false);

    await db.assignTagToArtist(AssignedTagsCompanion(artist: Value(artistId), tag: Value(tag1Id)));

    var artistData = await db.getArtistDataById(artistId).first;
    expect(artistData?.hasTag(tag1!), true);
    expect(artistData?.hasTag(tag2!), false);
  });
}
