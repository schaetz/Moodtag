import 'package:flutter/material.dart';
import 'package:moodtag/model/entities/entities.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';

abstract class AppSettingsEvent extends LibraryEvent {
  const AppSettingsEvent();
}

class CreateTagCategory extends AppSettingsEvent {
  final String name;
  final Color color;

  const CreateTagCategory(this.name, {required this.color});

  @override
  List<Object> get props => [name, color];
}

class DeleteTagCategory extends AppSettingsEvent {
  final TagCategory deletedCategory;
  final TagCategory? insertedCategory;

  const DeleteTagCategory(this.deletedCategory, {this.insertedCategory});

  @override
  List<Object?> get props => [deletedCategory, insertedCategory];
}

class EditTagCategory extends AppSettingsEvent {
  final TagCategory tagCategory;
  final String newName;
  final Color newColor;

  const EditTagCategory(this.tagCategory, {required this.newName, required this.newColor});

  @override
  List<Object> get props => [tagCategory, newName, newColor];
}

// Last.fm

abstract class LastFmEvent extends AppSettingsEvent {
  const LastFmEvent();
}

class LastFmAccountUpdated extends LastFmEvent {
  final LastFmAccount? lastFmAccount;
  final Object? error;

  const LastFmAccountUpdated({this.lastFmAccount, this.error});

  @override
  List<Object?> get props => [lastFmAccount, error];
}

class AddLastFmAccount extends LastFmEvent {
  final String accountName;

  const AddLastFmAccount(this.accountName);

  @override
  List<Object?> get props => [accountName];
}

class RemoveLastFmAccount extends LastFmEvent {
  const RemoveLastFmAccount();

  @override
  List<Object?> get props => [];
}

class UpdateLastFmAccountInfo extends LastFmEvent {
  const UpdateLastFmAccountInfo();

  @override
  List<Object?> get props => [];
}
