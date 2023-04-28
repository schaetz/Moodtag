import 'package:flutter/material.dart';
import 'package:moodtag/exceptions/internal_exception.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';

class DeleteDialog<T> extends AbstractDialog<bool> {
  static void openNew<T>(BuildContext context,
      {required T entityToDelete, required Function() deleteHandler, bool resetLibrary = false}) {
    new DeleteDialog<T>(context,
        entityToDelete: entityToDelete, deleteHandler: deleteHandler, resetLibrary: resetLibrary);
  }

  Function() deleteHandler;
  T? entityToDelete;
  bool resetLibrary = false;

  DeleteDialog(BuildContext context,
      {required this.entityToDelete, required this.deleteHandler, this.resetLibrary = false})
      : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return SimpleDialog(
      title: FutureBuilder<String>(
          future: determineDialogTextForDeleteEntity(context),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Text(snapshot.data!);
            } else {
              return Text('');
            }
          }),
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
                  onPressed: () => closeDialog(context, result: false),
                  child: const Text('No'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<String> determineDialogTextForDeleteEntity(BuildContext context) async {
    final repository = context.read<Repository>();

    print(resetLibrary);
    if (resetLibrary) {
      return 'Are you sure that you want to reset the library and delete all artists and tags?';
    } else if (entityToDelete is Artist) {
      Artist artist = entityToDelete as Artist;
      return 'Are you sure that you want to delete the artist "${artist.name}"?';
    } else if (entityToDelete is Tag) {
      Tag tag = entityToDelete as Tag;
      final mainMessage = 'Are you sure that you want to delete the tag "${tag.name}"?';
      String appendix = '';
      final artistsWithTagStream = await repository.getArtistsWithTag(tag.id);
      if (await artistsWithTagStream.isEmpty) {
        appendix = ' It is currently not assigned to any artist.';
      } else {
        await artistsWithTagStream.first.then((artistsWithTag) {
          if (artistsWithTag.length == 0) {
            appendix = ' It is currently not assigned to any artist.';
          } else if (artistsWithTag.length == 1) {
            appendix = ' There is currently 1 artist which uses this tag.';
          } else {
            appendix = ' There are currently ${artistsWithTag.length} artists which use this tag.';
          }
        });
      }
      return mainMessage + appendix;
    } else {
      return 'Error: Invalid entity';
    }
  }

  void deleteEntity(BuildContext context) async {
    if (entityToDelete == null && !resetLibrary) {
      throw new InternalException("The delete dialog was called with invalid arguments.");
    }

    await deleteHandler();
    closeDialog(context);
  }
}
