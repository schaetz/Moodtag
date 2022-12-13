import 'package:flutter/material.dart';
import 'package:moodtag/components/simple_text_input_dialog_base.dart';
// import 'package:moodtag/exceptions/db_request_response.dart';
// import 'package:moodtag/exceptions/name_already_taken_exception.dart';
// import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/utils/i10n.dart';

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

  // void _addEntity(BuildContext context, String newInput, O preselectedOther) async {
  //   List<String> inputElements = processMultilineInput(newInput);
  //   List<DbRequestResponse> exceptionResponses = [];
  //
  //   for (String newEntityName in inputElements) {
  //     DbRequestResponse response;
  //
  //     if (E == Artist) {
  //       response = await createArtistOrEditExistingArtist(bloc, newEntityName, preselectedOther as Tag);
  //     } else if (E == Tag) {
  //       response = await createTagOrEditExistingTag(bloc, newEntityName, preselectedOther as Artist);
  //     } else {
  //       response = new DbRequestResponse.fail(new InvalidArgumentException('Invalid entity type'), [newEntityName]);
  //     }
  //
  //     if (response.didFail()) exceptionResponses.add(response);
  //   }
  //
  //   closeDialog(context);
  //
  //   if (exceptionResponses.isNotEmpty) {
  //     showErrorInSnackbar(exceptionResponses, preselectedOther != null);
  //   }
  // }

  // void showErrorInSnackbar(List<DbRequestResponse> exceptionResponses, bool preselectedOther) {
  //   UserReadableException? userFeedbackException = getHighestSeverityExceptionForMultipleResponses(exceptionResponses);
  //
  //   if (userFeedbackException == null) {
  //     // Ignore if there was no actual error (this should never happen)
  //   } else if (userFeedbackException is NameAlreadyTakenException && preselectedOther) {
  //     // Do not show an error message if the already existing entity
  //     // is assigned to a preselected other entity
  //   } else {
  //     final entityDenotationPlural = I10n.getEntityDenotation(type: E, plural: true);
  //     final errorReason = userFeedbackException is NameAlreadyTakenException
  //         ? 'One or several $entityDenotationPlural already exist'
  //         : userFeedbackException.message;
  //     final errorMessage = 'Error while adding $entityDenotationPlural: $errorReason';
  //
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
  //   }
  // }
}
