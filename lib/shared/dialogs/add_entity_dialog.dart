import 'package:flutter/material.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/dialogs/simple_text_input_dialog_base.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';
import 'package:moodtag/shared/utils/i10n.dart';

import 'abstract_dialog.dart';

/// Dialog for adding generic entities (artists or tags)
///
/// E: Type of the entity to add
/// O: Type of the other entity that might be affected
/// S: Type of the suggested entities
/// (E=artist => O=tag and vice versa)
class AddEntityDialog<E, O> extends AbstractDialog<E> {
  final O? preselectedOtherEntity;
  late final Function(String) onSendInput;
  final List<NamedEntity>? suggestedEntities;

  AddEntityDialog(
    BuildContext context, {
    O? this.preselectedOtherEntity,
    required Function(String) this.onSendInput,
    Function(E?)? onTerminate,
    this.suggestedEntities = null,
  }) : super(context, onTerminate: onTerminate);

  @override
  Widget buildDialog(BuildContext context) {
    return SimpleTextInputDialogBase(
      message: 'Enter the name of the ${I10n.getEntityDenotation(type: E, plural: false)}:',
      confirmationButtonLabel: 'OK',
      onSendInput: (String newInput) {
        this.onSendInput(newInput);
        this.closeDialog(context);
      },
      suggestedEntities: this.suggestedEntities,
    );
  }
}

typedef AddArtistDialog = AddEntityDialog<Artist, Tag>;
typedef AddTagDialog = AddEntityDialog<Tag, Artist>;
