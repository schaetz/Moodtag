import 'package:equatable/equatable.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

abstract class TagEvent extends Equatable {
  const TagEvent();
}

class GetSelectedTag extends TagEvent {
  final int id;

  GetSelectedTag(this.id);

  @override
  List<Object> get props => [];
}

class GetTags extends TagEvent {
  @override
  List<Object> get props => [];
}

class SelectTag extends TagEvent {
  final Tag tag;

  const SelectTag(this.tag);

  @override
  List<Object> get props => [tag];
}

class CreateTag extends TagEvent {
  final String name;

  const CreateTag(this.name);

  @override
  List<Object> get props => [name];
}

class DeleteTag extends TagEvent {
  final Tag tag;

  const DeleteTag(this.tag);

  @override
  List<Object> get props => [tag];
}
