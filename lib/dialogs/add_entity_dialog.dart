import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/database/moodtag_db.dart';
import 'package:moodtag/exceptions/db_request_response.dart';
import 'package:moodtag/exceptions/invalid_argument_exception.dart';
import 'package:moodtag/utils/i10n.dart';
import 'package:moodtag/utils/helpers.dart';

/// Dialog for adding generic entities (artists or tags)
///
/// E: Type of the entity to add
/// O: Type of the other entity that might be affected
/// (E=artist => O=tag and vice versa)
class AddEntityDialog<E, O> extends AbstractDialog {

  static void openAddArtistDialog(BuildContext context, {Tag preselectedTag}) {
    if (preselectedTag != null) {
      new AddEntityDialog<Artist, Tag>
          .withPreselectedOtherEntity(context, preselectedTag).show();
    } else {
      new AddEntityDialog<Artist, Tag>(context).show();
    }
  }

  static void openAddTagDialog(BuildContext context, {Artist preselectedArtist}) {
    if (preselectedArtist != null) {
      new AddEntityDialog<Tag, Artist>
          .withPreselectedOtherEntity(context, preselectedArtist).show();
    } else {
      new AddEntityDialog<Tag, Artist>(context).show();
    }
  }

  O preselectedOtherEntity;

  AddEntityDialog(BuildContext context) : super(context);
  AddEntityDialog.withPreselectedOtherEntity(BuildContext context,
      this.preselectedOtherEntity) : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    var newInput;
    return SimpleDialog(
      title: Text('Enter the name of the ${_getEntityDenotation()}:'),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                    maxLines: null,
                    maxLength: 255,
                    onChanged: (value) => newInput = value.trim()
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: () async {
                    if (newInput == null || newInput.isEmpty) {
                      return;
                    }
                    _addOrEditEntity(context, newInput, preselectedOtherEntity);
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  String _getEntityDenotation({bool plural=false}) {
    String denotationSingular = 'entity';
    String denotationPlural = 'entities';

    if (E == Artist) {
      denotationSingular = I10n.ARTIST_DENOTATION_SINGULAR;
      denotationPlural = I10n.ARTIST_DENOTATION_PLURAL;
    } else if (E == Tag) {
      denotationSingular = I10n.TAG_DENOTATION_SINGULAR;
      denotationPlural = I10n.TAG_DENOTATION_PLURAL;
    }

    return plural ? denotationPlural : denotationSingular;
  }

  void _addOrEditEntity(BuildContext context, String newInput, O preselectedOther) async {
    List<String> inputElements = processMultilineInput(newInput);
    List<DbRequestResponse> exceptionResponses = [];
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);

    for (String newEntityName in inputElements) {
      DbRequestResponse response;

      if (E == Artist) {
        response = await _addOrEditArtist(bloc, newEntityName, preselectedOther as Tag);
      } else if (E == Tag) {
        response = await _addOrEditTag(bloc, newEntityName, preselectedOther as Artist);
      } else {
        response = new DbRequestResponse.fail(
            new InvalidArgumentException('Invalid entity type')
        );
      }

      if (response.didFail())
        exceptionResponses.add(response);
    }

    closeDialog(context);

    if (exceptionResponses.isNotEmpty) {
      // TODO Check exception type
      final errorMessage = 'Error while adding ${_getEntityDenotation(plural: true)}: '
        + 'One or several ${_getEntityDenotation(plural: true)} already exist';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage))
      );
    }
  }

  Future<DbRequestResponse<Artist>> _addOrEditArtist(MoodtagBloc bloc, String newArtistName, Tag preselectedTag) async {
    final createArtistResponse = await bloc.createArtist(newArtistName);

    if (createArtistResponse.didSucceed() && preselectedTag != null) {
      Artist newArtist = createArtistResponse.changedEntity;
      await bloc.assignTagToArtist(newArtist, preselectedTag);
    }

    return createArtistResponse;
  }

  Future<DbRequestResponse<Tag>> _addOrEditTag(MoodtagBloc bloc, String newTagName, Artist preselectedArtist) async {
    // TODO Change method analogously to _addOrEditArtist
    int newTagId = await bloc.createTag(newTagName)
      .catchError((e) {
        // If there is a preselected artist, just ignore the exception
        // and add the preselected artist to the existing tag in "whenComplete"
        if (preselectedArtist == null) {
          return new DbRequestResponse.fail(e);
        }
      });

    Tag newTag = await bloc.getTagById(newTagId);
    if (preselectedArtist != null) {
      await bloc.assignTagToArtist(preselectedArtist, newTag);
    }

    return new DbRequestResponse.success(newTag);
  }

}