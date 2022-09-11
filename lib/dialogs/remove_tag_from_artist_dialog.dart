import 'package:flutter/widgets.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository/repository.dart';
import 'package:provider/provider.dart';

class RemoveTagFromArtistDialog extends DeleteDialog<Tag> {
  static void openNew(BuildContext context, Tag tag, Artist artist) {
    new RemoveTagFromArtistDialog(context, tag, artist).show();
  }

  Tag tagToRemove;
  Artist artistToRemoveFrom;

  RemoveTagFromArtistDialog(BuildContext context, this.tagToRemove, this.artistToRemoveFrom)
      : super(context, entityToDelete: tagToRemove);

  @override
  Future<String> determineDialogTextForDeleteEntity(BuildContext context) {
    return new Future<String>(
        () => 'Do you want to remove the tag "${tagToRemove.name}" from the artist "${artistToRemoveFrom.name}"?');
  }

  @override
  void deleteEntity(BuildContext context) {
    final bloc = Provider.of<Repository>(context, listen: false);
    bloc.removeTagFromArtist(artistToRemoveFrom, tagToRemove);

    closeDialog(context);
  }
}
