import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class DeleteDialog<T> extends AbstractDialog {

  static void openNew<T>(BuildContext context, T entity) {
    new DeleteDialog<T>(context, entity).show();
  }

  T entity;

  DeleteDialog(BuildContext context, this.entity) : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return SimpleDialog(
      title: Text(_determineDialogTextForDeleteEntity(context, entity)),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: () => _deleteEntity(context, entity),
                  child: const Text('Yes'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: () => closeDialog(context),
                  child: const Text('No'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  String _determineDialogTextForDeleteEntity(BuildContext context, T entity) {
    final libraryProvider = Provider.of<Library>(context, listen: false);

    if (entity is Artist) {
      return 'Are you sure that you want to delete the artist "${entity.name}"?';
    } else if (entity is Tag) {
      final mainMessage = 'Are you sure that you want to delete the tag "${entity.name}"?';
      final artistsWithTag = libraryProvider.getArtistsWithTag(entity).length;
      if (artistsWithTag > 0) {
        return mainMessage + ' There are currently ${artistsWithTag} artists which use this tag.';
      } else {
        return mainMessage + ' It is currently not assigned to any artist.';
      }
    } else {
      return 'Error: Invalid entity';
    }
  }

  void _deleteEntity(BuildContext context, T entity) {
    final libraryProvider = Provider.of<Library>(context, listen: false);

    if (entity is Artist) {
      libraryProvider.deleteArtist(entity);
    } else if (entity is Tag) {
      libraryProvider.deleteTag(entity);
    } else {
      print('Error: Invalid entity');
    }

    closeDialog(context);
  }

}