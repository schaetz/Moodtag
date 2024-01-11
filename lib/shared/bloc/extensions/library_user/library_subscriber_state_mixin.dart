import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config.dart';
import 'package:moodtag/model/repository/library_subscription/config/subscription_config_factory.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';

import 'library_subscription_sub_state.dart';

/// Mixin for Bloc states of blocs that subscribe to the library;
/// adds getters for all artists / tags and a method to update
/// the sub state for a single subscription
abstract mixin class LibrarySubscriberStateMixin {
  LibrarySubscriptionSubState get librarySubscriptionSubState;

  LoadedData<ArtistsList> get allArtists {
    final allArtistsListConfig = SubscriptionConfigFactory.getAllArtistsListConfig();
    final loadedData = librarySubscriptionSubState.getCurrentDataForSubscription(allArtistsListConfig);
    if (loadedData != null && loadedData.loadingStatus == LoadingStatus.success) {
      return LoadedData<ArtistsList>.success(loadedData.data);
    }
    return LoadedData.error(message: 'The ArtistsList stream is not available.');
  }

  LoadedData<TagsList> get allTags {
    final allTagsListConfig = SubscriptionConfigFactory.getAllTagsListConfig();
    final loadedData = librarySubscriptionSubState.getCurrentDataForSubscription(allTagsListConfig);
    if (loadedData != null && loadedData.loadingStatus == LoadingStatus.success) {
      return LoadedData<TagsList>.success(loadedData.data);
    }
    return LoadedData.error(message: 'The TagsList stream is not available.');
  }

  LibrarySubscriberStateMixin copyWith({LibrarySubscriptionSubState? librarySubscription});

  LibrarySubscriberStateMixin updateLibrarySubscription(SubscriptionConfig subscriptionConfig, LoadedData loadedData) {
    return this.copyWith(librarySubscription: librarySubscriptionSubState.update(subscriptionConfig, loadedData));
  }
}
