import 'package:moodtag/model/database/moodtag_db.dart';

import 'LibraryEvent.dart';

abstract class TagEvent extends LibraryEvent {
  const TagEvent();
}

class TagUpdated extends TagEvent {
  final Tag tag;

  TagUpdated(this.tag);

  @override
  List<Object> get props => [tag];
}

class TagsListUpdated extends TagEvent {
  final List<Tag> tags;

  TagsListUpdated(this.tags);

  @override
  List<Object> get props => [tags];
}

class OpenCreateTagDialog extends TagEvent {
  @override
  List<Object> get props => [];
}

class CloseCreateTagDialog extends TagEvent {
  @override
  List<Object> get props => [];
}

class CreateTags extends TagEvent {
  final String input;

  const CreateTags(this.input);

  @override
  List<Object> get props => [input];
}

class DeleteTag extends TagEvent {
  final Tag tag;

  const DeleteTag(this.tag);

  @override
  List<Object> get props => [tag];
}
