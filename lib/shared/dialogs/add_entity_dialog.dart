import 'package:flutter/material.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';
import 'package:moodtag/shared/utils/i10n.dart';
import 'package:moodtag/shared/widgets/text_input/simple_text_input_dialog_base.dart';

import 'abstract_dialog.dart';

/// Dialog for adding generic entities (artists or tags)
///
/// E: Type of the entity to add
/// O: Type of the other entity that might be affected
/// S: Type of the suggested entities
/// (E=artist => O=tag and vice versa)
class AddEntityDialog<E, O> extends AbstractDialog<E> {
  static AddEntityDialog<Artist, Tag> openAddArtistDialog(BuildContext context,
          {Tag? preselectedTag,
          required Function(String) onSendInput,
          Function(dynamic)? onTerminate,
          List<NamedEntity>? suggestedEntities = null}) =>
      new AddEntityDialog<Artist, Tag>(context,
          preselectedOtherEntity: preselectedTag,
          onSendInput: onSendInput,
          onTerminate: onTerminate,
          suggestedEntities: suggestedEntities);

  static AddEntityDialog<Tag, Artist> openAddTagDialog(BuildContext context,
          {Artist? preselectedArtist,
          required Function(String) onSendInput,
          Function(dynamic)? onTerminate,
          List<NamedEntity>? suggestedEntities = null}) =>
      new AddEntityDialog<Tag, Artist>(context,
          preselectedOtherEntity: preselectedArtist,
          onSendInput: onSendInput,
          onTerminate: onTerminate,
          suggestedEntities: suggestedEntities);

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
