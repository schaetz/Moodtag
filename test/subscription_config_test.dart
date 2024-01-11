import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/library_subscription/config/library_query_filter.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config.dart';
import 'package:test/test.dart';

void main() {
  test('Subscription configs should be equal if the data type is equal and there are no filters', () async {
    final config1 = SubscriptionConfig(ArtistsList);
    final config2 = SubscriptionConfig(ArtistsList);

    expect(config1 == config2, true);
  });

  test('Subscription configs should NOT be equal if they have different names', () async {
    final config1 = SubscriptionConfig(ArtistsList);
    final config2 = SubscriptionConfig.named('config2', ArtistsList);

    expect(config1 == config2, false);
  });

  test('Subscription configs should NOT be equal if they have different data types', () async {
    final config1 = SubscriptionConfig(ArtistsList);
    final config2 = SubscriptionConfig(TagsList);

    expect(config1 == config2, false);
  });

  test('Subscription configs should be equal if they have identical query filters', () async {
    final filter1 =
        LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {Tag(id: 234, name: 'tag234')});
    final config1 = SubscriptionConfig(ArtistsList, filter: filter1);

    final filter2 =
        LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {Tag(id: 234, name: 'tag234')});
    final config2 = SubscriptionConfig(ArtistsList, filter: filter2);

    expect(config1 == config2, true);

    final configMap = Map<LibraryQueryFilter, bool>()..putIfAbsent(filter1, () => true);
    expect(configMap.containsKey(filter2), true);
  });

  test('Subscription configs should NOT be equal if they have different search IDs', () async {
    final filter1 =
        LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {Tag(id: 234, name: 'tag234')});
    final config1 = SubscriptionConfig(ArtistsList, filter: filter1);

    final filter2 =
        LibraryQueryFilter(searchId: 789, searchItem: 'some item', entityFilters: {Tag(id: 234, name: 'tag234')});
    final config2 = SubscriptionConfig(ArtistsList, filter: filter2);

    expect(config1 == config2, false);

    final configMap = Map<LibraryQueryFilter, bool>()..putIfAbsent(filter1, () => true);
    expect(configMap.containsKey(filter2), false);
  });

  test('Subscription configs should NOT be equal if they have different search items', () async {
    final filter1 =
        LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {Tag(id: 234, name: 'tag234')});
    final config1 = SubscriptionConfig(ArtistsList, filter: filter1);

    final filter2 =
        LibraryQueryFilter(searchId: 123, searchItem: 'different item', entityFilters: {Tag(id: 234, name: 'tag234')});
    final config2 = SubscriptionConfig(ArtistsList, filter: filter2);

    expect(config1 == config2, false);

    final configMap = Map<LibraryQueryFilter, bool>()..putIfAbsent(filter1, () => true);
    expect(configMap.containsKey(filter2), false);
  });

  test('Subscription configs should NOT be equal if they have different entity filters', () async {
    final filter1 =
        LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {Tag(id: 234, name: 'tag234')});
    final config1 = SubscriptionConfig(ArtistsList, filter: filter1);

    final filter2 =
        LibraryQueryFilter(searchId: 123, searchItem: 'some item', entityFilters: {Tag(id: 789, name: 'tag789')});
    final config2 = SubscriptionConfig(ArtistsList, filter: filter2);

    expect(config1 == config2, false);

    final configMap = Map<LibraryQueryFilter, bool>()..putIfAbsent(filter1, () => true);
    expect(configMap.containsKey(filter2), false);
  });
}
