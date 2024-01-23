import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:moodtag/shared/dialogs/abstract_dialog.dart';
import 'package:moodtag/shared/exceptions/internal/internal_exception.dart';

import 'delete_entity_dialog_config.dart';

mixin DeleteEntityDialogMixin<E, T> on AbstractDialog<T> {
  abstract DeleteEntityDialogConfig<E> deleteEntityDialogConfig;

  Future<String> determineDialogTextForDeleteEntity(BuildContext context) async {
    final repository = context.read<Repository>();
    final config = deleteEntityDialogConfig;

    if (config.resetLibrary) {
      return 'Are you sure that you want to reset the library and delete all artists and tags?';
    } else if (config.entityToDelete is Artist) {
      Artist artist = config.entityToDelete as Artist;
      return 'Are you sure that you want to delete the artist "${artist.name}"?';
    } else if (config.entityToDelete is Tag) {
      Tag tag = config.entityToDelete as Tag;
      final mainMessage = 'Are you sure that you want to delete the tag "${tag.name}"?';
      String appendix = await _getRelatedEntitiesMessage(repository);
      return '$mainMessage $appendix';
    } else if (config.entityToDelete is TagCategory) {
      TagCategory tagCategory = config.entityToDelete as TagCategory;
      final mainMessage = 'Are you sure that you want to delete the tag category "${tagCategory.name}"?';
      String appendix = await _getRelatedEntitiesMessage(repository);
      return '$mainMessage $appendix';
    } else {
      return 'Error: Invalid entity';
    }
  }

  void deleteEntity(BuildContext context) async {
    final config = deleteEntityDialogConfig;
    if (config.entityToDelete == null && !config.resetLibrary) {
      throw new InternalException("The delete dialog was called with invalid arguments.");
    }

    await config.deleteHandler();
    closeDialog(context);
  }

  Future<String> _getRelatedEntitiesMessage(Repository repository) async {
    final config = deleteEntityDialogConfig;
    late final String deletedEntityDenotation;
    late final String relatedEntityDenotation;
    late final List relatedEntities;
    switch (E) {
      case Tag:
        deletedEntityDenotation = 'tag';
        relatedEntityDenotation = 'artist';
        relatedEntities = await repository.getArtistsDataHavingTag(config.entityToDelete as Tag).first;
        break;
      case TagCategory:
        deletedEntityDenotation = 'category';
        relatedEntityDenotation = 'tag';
        relatedEntities = await repository.getTagsWithCategory(config.entityToDelete as TagCategory).first;
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
