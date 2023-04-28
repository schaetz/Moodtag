import 'package:flutter/widgets.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/database/moodtag_db.dart';

class RemoveTagFromArtistDialog extends DeleteDialog<Tag> {
  static void openNew(BuildContext context, Tag tag, Artist artist, Function() removeTagHandler) {
    new RemoveTagFromArtistDialog(context, tag, artist, removeTagHandler);
  }

  Function() removeTagHandler;
  Tag tagToRemove;
  Artist artistToRemoveFrom;

  RemoveTagFromArtistDialog(BuildContext context, this.tagToRemove, this.artistToRemoveFrom, this.removeTagHandler)
      : super(context, entityToDelete: tagToRemove, deleteHandler: removeTagHandler);

  @override
  Future<String> determineDialogTextForDeleteEntity(BuildContext context) {
    return new Future<String>(
        () => 'Do you want to remove the tag "${tagToRemove.name}" from the artist "${artistToRemoveFrom.name}"?');
  }
}
