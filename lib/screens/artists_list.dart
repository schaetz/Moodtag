import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';

class ArtistsListScreen extends StatelessWidget {

  final String title;
  final ValueChanged<Artist> onArtistTapped;

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  ArtistsListScreen(
      {this.title, @required this.onArtistTapped});

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
              return _buildArtistRow(library.artists[i], onArtistTapped);
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
    );
  }

  Widget _buildArtistRow(Artist artist, ValueChanged<Artist> onTapped) {
    return ListTile(
      title: Text(
        artist.name,
        style: listEntryStyle,
      ),
      onTap: () => onArtistTapped(artist),
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
                          Provider.of<Library>(context, listen: false).addArtist(
                            Artist(newArtistName));
                          Navigator.pop(context);
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

}
