import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';
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
                  onPressed: () {
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
      denotationSingular = Artist.denotationSingular;
      denotationPlural = Artist.denotationPlural;
    } else if (E == Tag) {
      denotationSingular = Tag.denotationSingular;
      denotationPlural = Tag.denotationPlural;
    }

    return plural ? denotationPlural : denotationSingular;
  }

  void _addOrEditEntity(BuildContext context, String newInput, O preselectedOther) {
    List<String> inputElements = processMultilineInput(newInput);
    List<String> errorElements = [];
    Library libraryProvider = Provider.of<Library>(context, listen: false);

    for (String newEntityName in inputElements) {
      bool error;

      if (E == Artist) {
        error = _addOrEditArtist(libraryProvider, newEntityName, preselectedOther as Tag);
      } else if (E == Tag) {
        error = _addOrEditTag(libraryProvider, newEntityName, preselectedOther as Artist);
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

  bool _addOrEditArtist(Library libraryProvider, String newArtistName, Tag preselectedTag) {
    Artist newArtist;
    bool error = false;

    try {
      final preselectedTagsList = createListWithSingleElementOrEmpty<Tag>(preselectedTag);
      newArtist = libraryProvider.createArtist(newArtistName, preselectedTagsList);
    } on NameAlreadyTakenException {
      // If there is a preselected tag, just ignore the exception
      // and add the preselected tag to the existing artist
      if (preselectedTag == null) {
        error = true;
      } else {
        newArtist.addTag(preselectedTag);
      }
    }

    return error;
  }

  bool _addOrEditTag(Library libraryProvider, String newTagName, Artist preselectedArtist) {
    Tag newTag;
    bool error = false;

    try {
      newTag = libraryProvider.createTag(newTagName);
    } on NameAlreadyTakenException {
      // If there is a preselected artist, just ignore the exception
      // and add the preselected artist to the existing tag in "finally"
      if (preselectedArtist == null) {
        error = true;
      }
    } finally {
      if (preselectedArtist != null) {
        preselectedArtist.addTag(newTag);
      }
    }

    return error;
  }

}