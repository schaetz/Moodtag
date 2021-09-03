import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/main.dart';
import 'package:moodtag/components/mt_bottom_nav_bar.dart';
import 'package:moodtag/exceptions/name_already_taken_exception.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';

class ArtistsListScreen extends StatelessWidget {

  final String title;
  final NavigationItemChanged onBottomNavBarTapped;
  final ArtistChanged onArtistTapped;

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  ArtistsListScreen({
    this.title,
    @required this.onBottomNavBarTapped,
    @required this.onArtistTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Consumer<Library>(
        builder: (context, library, child) {
          return ListView.separated(
            separatorBuilder: (pro, context) => Divider(color: Colors.black),
            padding: EdgeInsets.all(16.0),
            itemCount: library.artists.length,
            itemBuilder: (context, i) {
              return _buildArtistRow(context, library.artists[i], onArtistTapped);
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddArtistDialog(context);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
      bottomNavigationBar: MtBottomNavBar(context, NavigationItem.artists, onBottomNavBarTapped),
    );
  }

  Widget _buildArtistRow(BuildContext context, Artist artist, ArtistChanged onTapped) {
    return ListTile(
      title: Text(
        artist.name,
        style: listEntryStyle,
      ),
      onTap: () => onArtistTapped(context, artist),
    );
  }

  void _showAddArtistDialog(context) async {
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

}
