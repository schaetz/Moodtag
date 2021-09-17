import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'exception_dialog.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/helpers.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';

void showAddTagDialog(context, [Artist preselectedArtist]) async {
  var newInput;
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Enter one or multiple new tags (in separate lines):'),
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
  );
}

void _addOrEditTag(BuildContext context, String newInput, Artist preselectedArtist) {
  List<String> inputElements = processMultilineInput(newInput);
  List<String> errorElements = [];

  for (String newTagName in inputElements) {
    try {
      Provider.of<Library>(context, listen: false).createTag(newTagName);
      // TODO Cannot add to an unmodifiable list
      //Provider.of<Library>(context, listen: false)
      //    .getArtistByName(newArtistName).tags.add(preselectedTag);
    } on NameAlreadyTakenException {
      // If there is a preselected artist, just ignore the exception
      // and add the preselected artist to the existing tag
      if (preselectedArtist == null) {
        errorElements.add(newTagName);
      }
    }
  }
  Navigator.pop(context);

  if (errorElements.isNotEmpty) {
    showExceptionDialog(context, 'Error while adding tags', 'One or several tags already exist');
  }
}
