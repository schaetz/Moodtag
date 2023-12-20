import 'package:flutter/material.dart';
import 'package:moodtag/components/simple_text_input_dialog_base.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/utils/i10n.dart';

import 'abstract_dialog.dart';

/// Dialog for adding generic entities (artists or tags)
///
/// E: Type of the entity to add
/// O: Type of the other entity that might be affected
/// (E=artist => O=tag and vice versa)
class AddEntityDialog<E, O> extends AbstractDialog<E> {
  static AddEntityDialog<Artist, Tag> openAddArtistDialog(BuildContext context,
          {Tag? preselectedTag, required Function(String) onSendInput, Function(dynamic)? onTerminate}) =>
      new AddEntityDialog<Artist, Tag>(context,
          preselectedOtherEntity: preselectedTag, onSendInput: onSendInput, onTerminate: onTerminate);

  static AddEntityDialog<Tag, Artist> openAddTagDialog(BuildContext context,
          {Artist? preselectedArtist, required Function(String) onSendInput, Function(dynamic)? onTerminate}) =>
      new AddEntityDialog<Tag, Artist>(context,
          preselectedOtherEntity: preselectedArtist, onSendInput: onSendInput, onTerminate: onTerminate);

  O? preselectedOtherEntity;
  late Function(String) onSendInput;

  AddEntityDialog(BuildContext context,
      {O? this.preselectedOtherEntity, required Function(String) this.onSendInput, Function(E?)? onTerminate})
      : super(context, onTerminate: onTerminate);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return SimpleTextInputDialogBase(
        message: 'Enter the name of the ${I10n.getEntityDenotation(type: E, plural: false)}:',
        confirmationButtonLabel: 'OK',
        onSendInput: (String newInput) {
          this.onSendInput(newInput);
          this.closeDialog(context);
        });
  }
}
