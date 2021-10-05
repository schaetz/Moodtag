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

  T entityToDelete;

  DeleteDialog(BuildContext context, this.entityToDelete) : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return SimpleDialog(
      title: Text(determineDialogTextForDeleteEntity(context)),
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
                  onPressed: () => deleteEntity(context),
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

  String determineDialogTextForDeleteEntity(BuildContext context) {
    final libraryProvider = Provider.of<Library>(context, listen: false);

    if (entityToDelete is Artist) {
      Artist artist = entityToDelete as Artist;
      return 'Are you sure that you want to delete the artist "${artist.name}"?';
    } else if (entityToDelete is Tag) {
      Tag tag = entityToDelete as Tag;
      final mainMessage = 'Are you sure that you want to delete the tag "${tag.name}"?';
      final artistsWithTag = libraryProvider.getArtistsWithTag(tag).length;
      if (artistsWithTag > 0) {
        return mainMessage + ' There are currently ${artistsWithTag} artists which use this tag.';
      } else {
        return mainMessage + ' It is currently not assigned to any artist.';
      }
    } else {
      return 'Error: Invalid entity';
    }
  }

  void deleteEntity(BuildContext context) {
    final libraryProvider = Provider.of<Library>(context, listen: false);

    if (entityToDelete is Artist) {
      libraryProvider.deleteArtist(entityToDelete as Artist);
    } else if (entityToDelete is Tag) {
      libraryProvider.deleteTag(entityToDelete as Tag);
    } else {
      print('Error: Invalid entity');
    }

    closeDialog(context);
  }

}