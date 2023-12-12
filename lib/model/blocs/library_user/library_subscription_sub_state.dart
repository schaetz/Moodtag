import 'package:equatable/equatable.dart';
import 'package:moodtag/exceptions/internal/internal_exception.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_data.dart';

/// Property of Bloc states for blocs that are subscribed to the library
class LibrarySubscriptionSubState extends Equatable {
  final LoadedData<ArtistsList> loadedDataAllArtists;
  final LoadedData<TagsList> loadedDataAllTags;

  const LibrarySubscriptionSubState(
      {this.loadedDataAllArtists = const LoadedData.initial(), this.loadedDataAllTags = const LoadedData.initial()});

  @override
  List<Object?> get props => [loadedDataAllArtists, loadedDataAllTags];

  LibrarySubscriptionSubState copyWith({
    LoadedData<ArtistsList>? loadedDataAllArtists,
    LoadedData<TagsList>? loadedDataAllTags,
  }) {
    return LibrarySubscriptionSubState(
        loadedDataAllArtists: loadedDataAllArtists ?? this.loadedDataAllArtists,
        loadedDataAllTags: loadedDataAllTags ?? this.loadedDataAllTags);
  }

  LibrarySubscriptionSubState update<T extends List<DataClassWithEntityName>>(LoadedData<T> loadedData) {
    switch (T) {
      case ArtistsList:
        return this.copyWith(loadedDataAllArtists: loadedData as LoadedData<ArtistsList>);
      case TagsList:
        return this.copyWith(loadedDataAllTags: loadedData as LoadedData<TagsList>);
    }
    throw InternalException('The generic parameter to determine the type of the dataset to be updated is unknown');
  }
}
