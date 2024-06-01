import 'package:moodtag/model/entities/entities.dart';

import 'library_query_filter.dart';
import 'subscription_config.dart';

class SubscriptionConfigFactory {
  static const allArtistsSubscriptionName = 'all_artists';
  static const allTagsSubscriptionName = 'all_tags';
  static const allTagCategoriesSubscriptionName = 'all_tag_categories';

  static const filteredArtistsSubscriptionName = 'filtered_artists_list';
  static const filteredArtistsWithTagSubscriptionName = 'filtered_artists_with_tag';
  static const filteredTagsSubscriptionName = 'filtered_tags_list';

  static const artistByIdSubscriptionName = 'artist_by_id';
  static const tagByIdSubscriptionName = 'tag_by_id';

  static SubscriptionConfig getAllArtistsListConfig() =>
      SubscriptionConfig.immutable(allArtistsSubscriptionName, List<Artist>, filter: LibraryQueryFilter.none());

  static SubscriptionConfig getAllTagsListConfig() =>
      SubscriptionConfig.immutable(allTagsSubscriptionName, List<Tag>, filter: LibraryQueryFilter.none());

  static SubscriptionConfig getAllTagCategoriesListConfig() =>
      SubscriptionConfig.immutable(allTagCategoriesSubscriptionName, List<TagCategory>,
          filter: LibraryQueryFilter.none());

  static SubscriptionConfig getFilteredArtistsListConfig(LibraryQueryFilter filter) =>
      SubscriptionConfig(List<Artist>, name: filteredArtistsSubscriptionName, filter: filter);

  static SubscriptionConfig getFilteredArtistsWithTagListConfig(LibraryQueryFilter filter) =>
      SubscriptionConfig(List<Artist>, name: filteredArtistsWithTagSubscriptionName, filter: filter);

  static SubscriptionConfig getFilteredTagsListConfig(LibraryQueryFilter filter) =>
      SubscriptionConfig(List<Tag>, name: filteredTagsSubscriptionName, filter: filter);

  static SubscriptionConfig getArtistByIdConfig(int id) =>
      SubscriptionConfig(Artist, name: artistByIdSubscriptionName, filter: LibraryQueryFilter(searchId: id));

  static SubscriptionConfig getTagByIdConfig(int id) =>
      SubscriptionConfig(Tag, name: tagByIdSubscriptionName, filter: LibraryQueryFilter(searchId: id));
}
