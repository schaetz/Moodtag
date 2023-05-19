import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/repository/loaded_object.dart';

abstract class EntityLoaderUserState extends Equatable {
  late final LoadedObject<List<ArtistData>> allArtistsWithTags;
  late final LoadedObject<List<TagData>> allTags;

  @override
  List<Object> get props;

  EntityLoaderUserState copyWith(EntityLoaderUserState);
}
