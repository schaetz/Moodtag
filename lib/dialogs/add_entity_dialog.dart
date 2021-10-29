import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/database/moodtag_db.dart';
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
    List<String> errorElements = [];
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);

    for (String newEntityName in inputElements) {
      bool error;

      if (E == Artist) {
        var newArtistId = await _addOrEditArtist(bloc, newEntityName, preselectedOther as Tag);
        error = newArtistId != null;
      } else if (E == Tag) {
        error = await _addOrEditTag(bloc, newEntityName, preselectedOther as Artist);
      } else {
        error = true;
      }

      if (error)
        errorElements.add(newEntityName);
    }

    closeDialog(context);

    if (errorElements.isNotEmpty) {
      final errorMessage = 'Error while adding ${_getEntityDenotation(plural: true)}: '
        + 'One or several ${_getEntityDenotation(plural: true)} already exist';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage))
      );
    }
  }

  Future<int> _addOrEditArtist(MoodtagBloc bloc, String newArtistName, Tag preselectedTag) async {
    int newArtistId = await bloc.createArtist(newArtistName); // TODO Error handling
    Artist newArtist = await bloc.getArtistById(newArtistId);

    if (preselectedTag != null) {
      await bloc.assignTagToArtist(newArtist, preselectedTag);
    }

    return newArtistId;
  }

  Future<bool> _addOrEditTag(MoodtagBloc bloc, String newTagName, Artist preselectedArtist) async {
    Tag newTag;
    bool error = false;

    await bloc.createTag(newTagName)
      .catchError((e) {
        print(e.toString());
        // TODO Check error type
        // If there is a preselected artist, just ignore the exception
        // and add the preselected artist to the existing tag in "whenComplete"
        if (preselectedArtist == null) {
          error = true;
        }
      })
      .whenComplete(() async => {
        if (preselectedArtist != null) {
          await bloc.assignTagToArtist(preselectedArtist, newTag)
        }
      });

    return error;
  }

}