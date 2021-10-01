import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/dialogs/add_tag_dialog.dart';
import 'package:moodtag/main.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class ArtistDetailsPage extends Page {
  final String title;
  final Artist artist;
  final TagChanged onTagTapped;

  ArtistDetailsPage({
    this.title,
    @required this.artist,
    @required this.onTagTapped
  }) : super(key: ValueKey(artist));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return ArtistDetailsScreen(
              title: title,
              artist: artist,
              onTagTapped: onTagTapped,
          );
        });
  }
}

class ArtistDetailsScreen extends StatefulWidget {
  final String title;
  final Artist artist;
  final TagChanged onTagTapped;

  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  const ArtistDetailsScreen({
    @required this.title,
    @required this.artist,
    @required this.onTagTapped,
  });

  @override
  State<StatefulWidget> createState() => _ArtistDetailsScreenState();

}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen> {

  bool _tagEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer<Library>(
        builder: (context, library, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(widget.artist.name, style: ArtistDetailsScreen.artistNameStyle),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _buildTagChipsRow(context, library, widget.artist),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: ElevatedButton(
                    child: Text(_tagEditMode ? 'Finish editing' : 'Edit tags'),
                    onPressed: () => _toggleEditMode()
                  )
                )
              ]
            ),
          );
        }
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _tagEditMode = !_tagEditMode;
    });
  }

  List<Widget> _buildTagChipsRow(BuildContext context, Library library, Artist artist) {
    final tagsToDisplay = _tagEditMode ? library.tags : artist.tags;

    List<Widget> chipsList = tagsToDisplay.map(
              (tag) => _buildTagChip(context, artist, tag, (value) { })
           ).toList();
    if (_tagEditMode) {
      chipsList.add(_buildAddTagChip(context, artist));
    }
    return chipsList;
  }

  Widget _buildTagChip(BuildContext context, Artist artist, Tag tag, ValueChanged<Tag> onTapped) {
    return InputChip(
      label: Text(tag.name),
      selected: _tagEditMode && artist.tags.contains(tag),
      onPressed: () => _onTagChipPressed(artist, tag, onTapped)
    );
  }

  void _onTagChipPressed(Artist artist, Tag tag, ValueChanged<Tag> onTapped) {
    if (_tagEditMode) {
      if (artist.tags.contains(tag)) {
        artist.removeTag(tag);
      } else {
        artist.addTag(tag);
      }
    } else {
      onTapped(tag);
    }
  }

  Widget _buildAddTagChip(BuildContext context, Artist artist) {
    return InputChip(
      label: Text('+'),
      //backgroundColor: Colors.redAccent,
      onPressed: () => {
        showAddTagDialog(context, artist)
      }
    );
  }

}