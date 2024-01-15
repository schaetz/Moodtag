import 'package:flutter/material.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/exceptions/internal/internal_exception.dart';
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

    if (resetLibrary) {
      return 'Are you sure that you want to reset the library and delete all artists and tags?';
    } else if (entityToDelete is Artist) {
      Artist artist = entityToDelete as Artist;
      return 'Are you sure that you want to delete the artist "${artist.name}"?';
    } else if (entityToDelete is Tag) {
      Tag tag = entityToDelete as Tag;
      final mainMessage = 'Are you sure that you want to delete the tag "${tag.name}"?';
      String appendix = await _getRelatedEntitiesMessage(repository);
      return '$mainMessage $appendix';
    } else if (entityToDelete is TagCategory) {
      TagCategory tagCategory = entityToDelete as TagCategory;
      final mainMessage = 'Are you sure that you want to delete the tag category "${tagCategory.name}"?';
      String appendix = await _getRelatedEntitiesMessage(repository);
      return '$mainMessage $appendix';
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

  Future<String> _getRelatedEntitiesMessage(Repository repository) async {
    late final String deletedEntityDenotation;
    late final String relatedEntityDenotation;
    late final List relatedEntities;
    switch (T) {
      case Tag:
        deletedEntityDenotation = 'tag';
        relatedEntityDenotation = 'artist';
        relatedEntities = await repository.getArtistsDataHavingTag(entityToDelete as Tag).first;
        break;
      case TagCategory:
        deletedEntityDenotation = 'category';
        relatedEntityDenotation = 'tag';
        relatedEntities = await repository.getTagsWithCategory(entityToDelete as TagCategory).first;
        break;
      default:
        return '';
    }

    if (relatedEntities.length == 0) {
      return 'It is currently not assigned to any $relatedEntityDenotation.';
    } else if (relatedEntities.length == 1) {
      return 'There is currently 1 $relatedEntityDenotation which uses this $deletedEntityDenotation.';
    } else {
      return 'There are currently ${relatedEntities.length} ${relatedEntityDenotation}s which use this $deletedEntityDenotation.';
    }
  }
}
