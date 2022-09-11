import 'package:flutter/material.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';

class DeleteDialog<T> extends AbstractDialog<bool> {
  static void openNew<T>(BuildContext context, {T entityToDelete, bool resetLibrary = false}) {
    print(entityToDelete);
    new DeleteDialog<T>(context, entityToDelete: entityToDelete, resetLibrary: resetLibrary).show();
  }

  bool resetLibrary = false;
  T entityToDelete;

  DeleteDialog(BuildContext context, {this.entityToDelete, this.resetLibrary = false}) : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return SimpleDialog(
      title: FutureBuilder<String>(
          future: determineDialogTextForDeleteEntity(context),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data);
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
    final bloc = Provider.of<Repository>(context, listen: false);

    print(resetLibrary);
    if (resetLibrary) {
      return 'Are you sure that you want to reset the library and delete all artists and tags?';
    } else if (entityToDelete is Artist) {
      Artist artist = entityToDelete as Artist;
      return 'Are you sure that you want to delete the artist "${artist.name}"?';
    } else if (entityToDelete is Tag) {
      Tag tag = entityToDelete as Tag;
      final mainMessage = 'Are you sure that you want to delete the tag "${tag.name}"?';
      // TODO Return type of the artistsWithTag() call is a Stream, not a list of artists; needs to be fixed
      final artistsWithTag = bloc.artistsWithTag(tag);
      if (await artistsWithTag.isEmpty) {
        return mainMessage + ' It is currently not assigned to any artist.';
      } else {
        return mainMessage + ' There are currently ${artistsWithTag.length} artists which use this tag.';
      }
    } else {
      return 'Error: Invalid entity';
    }
  }

  void deleteEntity(BuildContext context) async {
    final bloc = Provider.of<Repository>(context, listen: false);

    if (resetLibrary) {
      await bloc.deleteAllArtists();
      await bloc.deleteAllTags();
    } else if (entityToDelete is Artist) {
      await bloc.deleteArtist(entityToDelete as Artist);
    } else if (entityToDelete is Tag) {
      await bloc.deleteTag(entityToDelete as Tag);
    } else {
      print('Error: Invalid entity');
      closeDialog(context, result: false);
    }

    closeDialog(context, result: true);
  }
}
