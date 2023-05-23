import 'package:moodtag/model/database/moodtag_db.dart';

import 'library_events.dart';

abstract class TagEvent extends LibraryEvent {
  const TagEvent();
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
