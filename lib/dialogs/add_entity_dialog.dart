import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/simple_text_input_dialog_base.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/events/artist_events.dart';
import 'package:moodtag/model/events/tag_events.dart';
import 'package:moodtag/utils/i10n.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';

/// Dialog for adding generic entities (artists or tags)
///
/// B: Bloc type
/// E: Type of the entity to add
/// O: Type of the other entity that might be affected
/// (E=artist => O=tag and vice versa)
class AddEntityDialog<B extends Bloc, E, O> extends AbstractDialog {
  static Future openAddArtistDialog<B extends Bloc>(BuildContext context, {Tag preselectedTag}) async {
    final dialog = preselectedTag != null
        ? new AddEntityDialog<B, Artist, Tag>.withPreselectedOtherEntity(context, preselectedTag)
        : new AddEntityDialog<B, Artist, Tag>(context);
    return await dialog.show();
  }

  static Future openAddTagDialog<B extends Bloc>(BuildContext context, {Artist preselectedArtist}) async {
    final dialog = preselectedArtist != null
        ? new AddEntityDialog<B, Tag, Artist>.withPreselectedOtherEntity(context, preselectedArtist)
        : new AddEntityDialog<B, Tag, Artist>(context);
    return await dialog.show();
  }

  O preselectedOtherEntity;

  AddEntityDialog(BuildContext context) : super(context);
  AddEntityDialog.withPreselectedOtherEntity(BuildContext context, this.preselectedOtherEntity) : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return SimpleTextInputDialogBase(
        message: 'Enter the name of the ${I10n.getEntityDenotation(type: E, plural: false)}:',
        confirmationButtonLabel: 'OK',
        onSendInput: (String newInput) {
          final createEntityEvent = (E == Artist)
              ? CreateArtists(newInput)
              : (E == Tag)
                  ? CreateTag(newInput)
                  : null;
          if (createEntityEvent == null) {
            // TODO Error handling
            return;
          }
          context.read<B>().add(createEntityEvent);
        }
        // _addEntity(context, newInput, preselectedOtherEntity)
        );
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

  void showErrorInSnackbar(List<DbRequestResponse> exceptionResponses, bool preselectedOther) {
    UserReadableException userFeedbackException = getHighestSeverityExceptionForMultipleResponses(exceptionResponses);

    if (userFeedbackException is NameAlreadyTakenException && preselectedOther) {
      // Do not show an error message if the already existing entity
      // is assigned to a preselected other entity
    } else {
      final entityDenotationPlural = I10n.getEntityDenotation(type: E, plural: true);
      final errorReason = userFeedbackException is NameAlreadyTakenException
          ? 'One or several $entityDenotationPlural already exist'
          : userFeedbackException.message;
      final errorMessage = 'Error while adding $entityDenotationPlural: $errorReason';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
