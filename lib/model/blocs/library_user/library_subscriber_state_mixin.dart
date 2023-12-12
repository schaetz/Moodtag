import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

import 'library_subscription_sub_state.dart';

/// Mixin for Bloc states of blocs that subscribe to the library;
/// adds a method to update the sub state for a single subscription
abstract mixin class LibrarySubscriberStateMixin {
  LibrarySubscriptionSubState get librarySubscriptionSubState;
  LoadedData<ArtistsList> get allArtists => librarySubscriptionSubState.loadedDataAllArtists;
  LoadedData<TagsList> get allTags => librarySubscriptionSubState.loadedDataAllTags;

  LibrarySubscriberStateMixin copyWith({LibrarySubscriptionSubState? librarySubscription});

  LibrarySubscriberStateMixin updateLibrarySubscription<T extends List<DataClassWithEntityName>>(
      LoadedData<T> loadedData) {
    return this.copyWith(librarySubscription: librarySubscriptionSubState.update(loadedData));
  }
}
