import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/model/repository/library_subscription/config/library_query_filter.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config.dart';
import 'package:test/test.dart';

void main() {
  final Tag tag234 = Tag(
      id: 234,
      name: 'tag234',
      color: 0,
      colorMode: 0,
      category: TagCategory(id: 987, name: 'cat987', color: 3),
      frequency: 3);

  test('Subscription configs should be equal if the data type is equal and there are no filters', () async {
    final config1 = SubscriptionConfig(ArtistsList);
    final config2 = SubscriptionConfig(ArtistsList);

    expect(config1 == config2, true);
  });

  test('Subscription configs should be equal if they have identical data types, names and query filters', () async {
    final filter1 = LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {tag234});
    final config1 = SubscriptionConfig(ArtistsList, name: 'config1', filter: filter1);

    final filter2 = LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {tag234});
    final config2 = SubscriptionConfig(ArtistsList, name: 'config1', filter: filter2);

    expect(config1 == config2, true);

    final configMap = Map<SubscriptionConfig, bool>()..putIfAbsent(config1, () => true);
    expect(configMap.containsKey(config2), true);
  });

  test('Subscription configs should NOT be equal if one is immutable and the other isn\'t', () async {
    final config1 = SubscriptionConfig(ArtistsList, name: 'config1');
    final config2 = SubscriptionConfig.immutable('config1', ArtistsList);

    expect(config1 == config2, false);
  });

  test('Subscription configs should NOT be equal if they have different names', () async {
    final config1 = SubscriptionConfig(ArtistsList, name: 'config1');
    final config2 = SubscriptionConfig(ArtistsList, name: 'config2');

    expect(config1 == config2, false);
  });

  test('Subscription configs should NOT be equal if they have different data types', () async {
    final config1 = SubscriptionConfig(ArtistsList);
    final config2 = SubscriptionConfig(TagsList);

    expect(config1 == config2, false);
  });

  test('Subscription configs should NOT be equal if they have different search IDs', () async {
    final filter1 = LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {tag234});
    final config1 = SubscriptionConfig(ArtistsList, filter: filter1);

    final filter2 = LibraryQueryFilter(searchId: 789, searchItem: 'some item', entityFilters: {tag234});
    final config2 = SubscriptionConfig(ArtistsList, filter: filter2);

    expect(config1 == config2, false);

    final configMap = Map<SubscriptionConfig, bool>()..putIfAbsent(config1, () => true);
    expect(configMap.containsKey(config2), false);
  });

  test('Subscription configs should NOT be equal if they have different search items', () async {
    final filter1 = LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {tag234});
    final config1 = SubscriptionConfig(ArtistsList, filter: filter1);

    final filter2 = LibraryQueryFilter(searchId: 123, searchItem: 'different item', entityFilters: {tag234});
    final config2 = SubscriptionConfig(ArtistsList, filter: filter2);

    expect(config1 == config2, false);

    final configMap = Map<SubscriptionConfig, bool>()..putIfAbsent(config1, () => true);
    expect(configMap.containsKey(config2), false);
  });

  test('Subscription configs should NOT be equal if they have different entity filters', () async {
    final filter1 = LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {tag234});
    final config1 = SubscriptionConfig(ArtistsList, filter: filter1);

    final filter2 = LibraryQueryFilter(
        searchId: 123, searchItem: 'some item', entityFilters: {BaseTag(id: 789, name: 'tag789', colorMode: 0)});
    final config2 = SubscriptionConfig(ArtistsList, filter: filter2);

    expect(config1 == config2, false);

    final configMap = Map<SubscriptionConfig, bool>()..putIfAbsent(config1, () => true);
    expect(configMap.containsKey(config2), false);
  });
}
