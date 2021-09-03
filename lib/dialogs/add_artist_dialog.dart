import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

void showAddArtistDialog(context, [Tag preselectedTag]) async {
  var newArtistName;
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
                        onChanged: (value) => newArtistName = value
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: SimpleDialogOption(
                      onPressed: () {
                        if (newArtistName == null) {
                          return;
                        }
                        if (preselectedTag != null) {
                          _addOrEditArtistWithPreselectedTag(context, newArtistName, preselectedTag);
                        } else {
                          _addArtistWithoutPreselectedTag(context, newArtistName);
                        }
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

void _addArtistWithoutPreselectedTag(BuildContext context, String newArtistName) {
  try {
    Provider.of<Library>(context, listen: false)
        .createArtist(newArtistName);
    Navigator.pop(context);
  } on NameAlreadyTakenException catch (e) {
    _showArtistCreationExceptionDialog(context, e.message);
  }
}

void _addOrEditArtistWithPreselectedTag(BuildContext context, String newArtistName, Tag preselectedTag) {
  try {
    Provider.of<Library>(context, listen: false)
        .createArtist(newArtistName, [preselectedTag]);
  } on NameAlreadyTakenException {
    // TODO Cannot add to an unmodifiable list
    //Provider.of<Library>(context, listen: false)
    //    .getArtistByName(newArtistName).tags.add(preselectedTag);
  }
  Navigator.pop(context);
}

void _showArtistCreationExceptionDialog(BuildContext context, String exceptionMessage) {
  showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Could not create artist'),
        content: Text(exceptionMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      )
  );
}