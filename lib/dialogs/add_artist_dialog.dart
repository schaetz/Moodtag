import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'exception_dialog.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/helpers.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

void showAddArtistDialog(context, [Tag preselectedTag]) async {
  var newInput;
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
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
  );
}

void _addOrEditArtist(BuildContext context, String newInput, Tag preselectedTag) {
  List<String> inputElements = processMultilineInput(newInput);
  List<String> errorElements = [];

  for (String newArtistName in inputElements) {
    try {
      List<Tag> preselectedTagsList = preselectedTag != null
          ? [preselectedTag] : [];
      Provider.of<Library>(context, listen: false)
          .createArtist(newArtistName, preselectedTagsList);

      // TODO Cannot add to an unmodifiable list
      //Provider.of<Library>(context, listen: false)
      //    .getArtistByName(newArtistName).tags.add(preselectedTag);
      //Navigator.pop(context);
    } on NameAlreadyTakenException {
      // If there is a preselected tag, just ignore the exception
      // and add the preselected tag to the existing artist
      if (preselectedTag == null) {
        errorElements.add(newArtistName);
      }
    }
  }
  Navigator.pop(context);

  if (errorElements.isNotEmpty) {
    showExceptionDialog(context, 'Error while adding artists', 'One or several artists already exist');
  }
}