import 'package:flutter/widgets.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog.dart';
import 'package:moodtag/shared/dialogs/delete_entity/delete_entity_dialog_config.dart';

class RemoveTagFromArtistDialog extends DeleteEntityDialog<Tag> {
  Tag tagToRemove;
  Artist artistToRemoveFrom;
  Function() removeTagHandler;

  RemoveTagFromArtistDialog(BuildContext context, this.tagToRemove, this.artistToRemoveFrom,
      {required this.removeTagHandler})
      : super(
            context,
            DeleteEntityDialogConfig(
                options: [], // TODO Define options
                entityToDelete: tagToRemove,
                deleteHandler: removeTagHandler));

  @override
  Future<String> determineDialogTextForDeleteEntity(BuildContext context) {
    return new Future<String>(
        () => 'Do you want to remove the tag "${tagToRemove.name}" from the artist "${artistToRemoveFrom.name}"?');
  }
}
