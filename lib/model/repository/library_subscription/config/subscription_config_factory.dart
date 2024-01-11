import 'package:moodtag/model/database/join_data_classes.dart';

import 'library_query_filter.dart';
import 'subscription_config.dart';

class SubscriptionConfigFactory {
  static const allArtistsSubscriptionName = 'all_artists';
  static const allTagsSubscriptionName = 'all_tags';

  static const filteredArtistsSubscriptionName = 'filtered_artists_list';
  static const filteredArtistsWithTagSubscriptionName = 'filtered_artists_with_tag';
  static const filteredTagsSubscriptionName = 'filtered_tags_list';

  static const artistByIdSubscriptionName = 'artist_by_id';
  static const tagByIdSubscriptionName = 'tag_by_id';

  static SubscriptionConfig getAllArtistsListConfig() =>
      SubscriptionConfig.unique(allArtistsSubscriptionName, ArtistsList, filter: LibraryQueryFilter.none());

  static SubscriptionConfig getAllTagsListConfig() =>
      SubscriptionConfig.unique(allTagsSubscriptionName, TagsList, filter: LibraryQueryFilter.none());

  static SubscriptionConfig getFilteredArtistsListConfig(LibraryQueryFilter filter) =>
      SubscriptionConfig.notUnique(ArtistsList, name: filteredArtistsSubscriptionName, filter: filter);

  static SubscriptionConfig getFilteredArtistsWithTagListConfig(LibraryQueryFilter filter) =>
      SubscriptionConfig.notUnique(ArtistsList, name: filteredArtistsWithTagSubscriptionName, filter: filter);

  static SubscriptionConfig getFilteredTagsListConfig(LibraryQueryFilter filter) =>
      SubscriptionConfig.notUnique(TagsList, name: filteredTagsSubscriptionName, filter: filter);

  static SubscriptionConfig getArtistByIdConfig(int id) => SubscriptionConfig.notUnique(ArtistData,
      name: artistByIdSubscriptionName, filter: LibraryQueryFilter(searchId: id));

  static SubscriptionConfig getTagByIdConfig(int id) =>
      SubscriptionConfig.notUnique(TagData, name: tagByIdSubscriptionName, filter: LibraryQueryFilter(searchId: id));
}
