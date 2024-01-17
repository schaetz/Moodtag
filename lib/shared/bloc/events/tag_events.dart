import 'package:moodtag/model/database/moodtag_db.dart';

import 'library_events.dart';

abstract class TagEvent extends LibraryEvent {
  const TagEvent();
}

class CreateTags extends TagEvent {
  final String input;
  final TagCategory? tagCategory;
  final Artist? preselectedArtist;

  const CreateTags(this.input, {this.tagCategory, this.preselectedArtist});

  @override
  List<Object?> get props => [input, tagCategory, preselectedArtist];
}

class DeleteTag extends TagEvent {
  final Tag tag;

  const DeleteTag(this.tag);

  @override
  List<Object> get props => [tag];
}

class ChangeCategoryForTag extends TagEvent {
  final Tag tag;
  final TagCategory tagCategory;

  const ChangeCategoryForTag(this.tag, this.tagCategory);

  @override
  List<Object> get props => [tag, tagCategory];
}

class AddArtistsForTag extends TagEvent {
  final String input;
  final Tag tag;

  const AddArtistsForTag(this.input, this.tag);

  @override
  List<Object> get props => [input, tag];
}

class ToggleChecklistMode extends TagEvent {
  @override
  List<Object> get props => [];
}
