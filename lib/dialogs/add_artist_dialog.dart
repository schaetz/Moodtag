import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/models/library.dart';

void showAddArtistDialog(context) async {
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
                        if (newArtistName != null) {
                          try {
                            Provider.of<Library>(context, listen: false)
                                .createArtist(newArtistName);
                            Navigator.pop(context);
                          } on NameAlreadyTakenException catch (e) {
                            _showArtistCreationExceptionDialog(context, e.message);
                          }
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