import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loaded_data.dart';
import 'package:moodtag/shared/bloc/library_user/library_subscriber_state_mixin.dart';
import 'package:moodtag/shared/bloc/library_user/library_subscription_sub_state.dart';

class TagsListState extends Equatable with LibrarySubscriberStateMixin {
  final LibrarySubscriptionSubState librarySubscription;
  final LoadedData<TagsList> loadedDataFilteredTags;
  final bool displaySearchBar;
  final String searchItem;

  @override
  LibrarySubscriptionSubState get librarySubscriptionSubState => this.librarySubscription;

  const TagsListState({
    this.librarySubscription = const LibrarySubscriptionSubState(),
    this.loadedDataFilteredTags = const LoadedData.initial(),
    this.displaySearchBar = false,
    this.searchItem = '',
  });

  @override
  List<Object> get props => [librarySubscription, loadedDataFilteredTags, displaySearchBar, searchItem];

  @override
  TagsListState copyWith({
    LibrarySubscriptionSubState? librarySubscription,
    LoadedData<TagsList>? loadedDataFilteredTags,
    bool? displaySearchBar,
    String? searchItem,
  }) {
    return TagsListState(
      librarySubscription: librarySubscription ?? this.librarySubscription,
      loadedDataFilteredTags: loadedDataFilteredTags ?? this.loadedDataFilteredTags,
      displaySearchBar: displaySearchBar ?? this.displaySearchBar,
      searchItem: searchItem ?? this.searchItem,
    );
  }
}
