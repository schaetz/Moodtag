import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'abstract_dialog.dart';
import 'exception_dialog.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/helpers.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class AddTagDialog extends AbstractDialog {

  Artist preselectedArtist;

  AddTagDialog(BuildContext context) : super(context);

  AddTagDialog.withPreselectedArtist(BuildContext context,
      this.preselectedArtist)
      : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    var newInput;
    return SimpleDialog(
      title: const Text(
          'Enter one or multiple new tags (in separate lines):'),
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
                    if (newInput == null || newInput.isEmpty) {
                      return;
                    }
                    _addOrEditTag(context, newInput, preselectedArtist);
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

  void _addOrEditTag(BuildContext context, String newInput,
      Artist preselectedArtist) {
    List<String> inputElements = processMultilineInput(newInput);
    List<String> errorElements = [];
    final libraryProvider = Provider.of<Library>(context, listen: false);

    for (String newTagName in inputElements) {
      Tag newTag;

      try {
        newTag = libraryProvider.createTag(newTagName);
      } on NameAlreadyTakenException {
        // If there is a preselected artist, just ignore the exception
        // and add the preselected artist to the existing tag in "finally"
        if (preselectedArtist == null) {
          errorElements.add(newTagName);
        }
      } finally {
        if (preselectedArtist != null) {
          preselectedArtist.addTag(newTag);
        }
      }
    }

    closeDialog(context);

    if (errorElements.isNotEmpty) {
      new ExceptionDialog(context, 'Error while adding tags',
          'One or several tags already exist').show();
    }
  }

}

