import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

import 'library_events.dart';

abstract class TagEvent extends LibraryEvent {
  const TagEvent();
}

class TagUpdated extends TagEvent {
  final Tag? tag;
  final Object? error;

  const TagUpdated({this.tag, this.error});

  @override
  List<Object?> get props => [tag, error];
}

class TagsListUpdated extends TagEvent {
  final List<Tag>? tags;
  final Object? error;

  const TagsListUpdated({this.tags, this.error});

  @override
  List<Object?> get props => [tags, error];
}

class TagsListPlusUpdated extends TagEvent {
  final List<TagWithArtistFreq>? tagsWithArtistFreq;
  final Object? error;

  const TagsListPlusUpdated({this.tagsWithArtistFreq, this.error});

  @override
  List<Object?> get props => [tagsWithArtistFreq, error];
}

class TagsForArtistListUpdated extends TagEvent {
  final List<Tag>? tags;
  final Object? error;

  const TagsForArtistListUpdated({this.tags, this.error});

  @override
  List<Object?> get props => [tags, error];
}

class CreateTags extends TagEvent {
  final String input;
  final Artist? preselectedArtist;

  const CreateTags(this.input, {this.preselectedArtist});

  @override
  List<Object> get props => preselectedArtist != null ? [input, preselectedArtist!] : [input];
}

class DeleteTag extends TagEvent {
  final Tag tag;

  const DeleteTag(this.tag);

  @override
  List<Object> get props => [tag];
}

class AddArtistsForTag extends TagEvent {
  final String input;
  final Tag tag;

  const AddArtistsForTag(this.input, this.tag);

  @override
  List<Object> get props => [input, tag];
}

class ToggleArtistsForTagChecklist extends TagEvent {
  @override
  List<Object> get props => [];
}
