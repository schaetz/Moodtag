import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';
import 'exception_dialog.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/helpers.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class AddArtistDialog extends AbstractDialog {

  Tag preselectedTag;

  AddArtistDialog(BuildContext context) : super(context);
  AddArtistDialog.withPreselectedTag(BuildContext context, this.preselectedTag)
      : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    var newInput;
    return SimpleDialog(
      title: const Text('Enter the name of the artist:'),
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
                    onChanged: (value) => newInput = value.trim()
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    if (newInput == null) {
                      return;
                    }
                    _addOrEditArtist(context, newInput, preselectedTag);
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

  void _addOrEditArtist(BuildContext context, String newInput, Tag preselectedTag) {
    List<String> inputElements = processMultilineInput(newInput);
    List<String> errorElements = [];
    final libraryProvider = Provider.of<Library>(context, listen: false);

    for (String newArtistName in inputElements) {
      Artist newArtist;

      try {
        List<Tag> preselectedTagsList = preselectedTag != null
            ? [preselectedTag] : [];
        newArtist = libraryProvider.createArtist(newArtistName, preselectedTagsList);
      } on NameAlreadyTakenException {
        // If there is a preselected tag, just ignore the exception
        // and add the preselected tag to the existing artist in "finally"
        if (preselectedTag == null) {
          errorElements.add(newArtistName);
        }
      } finally {
        if (preselectedTag != null) {
          newArtist.addTag(preselectedTag);
        }
      }
    }

    closeDialog(context);

    if (errorElements.isNotEmpty) {
      new ExceptionDialog(context, 'Error while adding artists',
          'One or several artists already exist').show();
    }
  }

}