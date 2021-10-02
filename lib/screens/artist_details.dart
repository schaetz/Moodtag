import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/models/artist.dart';
import 'package:moodtag/models/library.dart';
import 'package:moodtag/models/tag.dart';

class ArtistDetailsScreen extends StatefulWidget {

  final Artist artist;

  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  ArtistDetailsScreen(BuildContext context) :
        artist = ModalRoute.of(context).settings.arguments as Artist;

  @override
  State<StatefulWidget> createState() => _ArtistDetailsScreenState();

}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen> {

  bool _tagEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context),
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
      //backgroundColor: Theme.of(context).accentColor,
      onPressed: () => AddEntityDialog.openAddTagDialog(context, preselectedArtist: artist)
    );
  }

}