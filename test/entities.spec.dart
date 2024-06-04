import 'package:moodtag/model/entities/entities.dart';
import 'package:test/test.dart';

void main() {
  test('Entities can be looked up in sets', () async {
    final artist1 = Artist(id: 1, name: 'artist1', orderingName: 'artist1', tags: {});
    final artist2 = Artist(id: 2, name: 'artist2', orderingName: 'artist2', tags: {});
    final artist3 = Artist(id: 3, name: 'artist3', orderingName: 'artist3', tags: {});
    final threeArtists = {artist1, artist2, artist3};

    final artist4 = Artist(id: 4, name: 'artist4', orderingName: 'artist4', tags: {});

    expect(threeArtists.containsEntity(artist1), true);
    expect(threeArtists.containsEntity(artist2), true);
    expect(threeArtists.containsEntity(artist3), true);
    expect(threeArtists.containsEntity(artist4), false);
  });

  test('Entities can be looked up in lists', () async {
    final artist1 = Artist(id: 1, name: 'artist1', orderingName: 'artist1', tags: {});
    final artist2 = Artist(id: 2, name: 'artist2', orderingName: 'artist2', tags: {});
    final artist3 = Artist(id: 3, name: 'artist3', orderingName: 'artist3', tags: {});
    final threeArtists = [artist1, artist2, artist3];

    final artist4 = Artist(id: 4, name: 'artist4', orderingName: 'artist4', tags: {});

    expect(threeArtists.containsEntity(artist1), true);
    expect(threeArtists.containsEntity(artist2), true);
    expect(threeArtists.containsEntity(artist3), true);
    expect(threeArtists.containsEntity(artist4), false);
  });
}
