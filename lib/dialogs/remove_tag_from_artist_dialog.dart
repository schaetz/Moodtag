import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/database/moodtag_db.dart';
import 'package:moodtag/dialogs/delete_dialog.dart';

class RemoveTagFromArtistDialog extends DeleteDialog<Tag> {

  static void openNew(BuildContext context, Tag tag, Artist artist) {
    new RemoveTagFromArtistDialog(context, tag, artist).show();
  }

  Tag tagToRemove;
  Artist artistToRemoveFrom;

  RemoveTagFromArtistDialog(BuildContext context, this.tagToRemove, this.artistToRemoveFrom) : super(context, tagToRemove);

  @override
  Future<String> determineDialogTextForDeleteEntity(BuildContext context) {
    return new Future<String>(() =>
      'Do you want to remove the tag "${tagToRemove.name}" from the artist "${artistToRemoveFrom.name}"?'
    );
  }

  @override
  void deleteEntity(BuildContext context) {
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);
    bloc.removeTagFromArtist(artistToRemoveFrom, tagToRemove);

    closeDialog(context);
  }

}