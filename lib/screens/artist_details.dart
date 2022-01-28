import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/database/moodtag_db.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';

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
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);

    return Scaffold(
      appBar: MtAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(widget.artist.name, style: ArtistDetailsScreen.artistNameStyle),
            ),
            StreamBuilder2<List<Tag>, List<Tag>>(
              streams: Tuple2(bloc.tags, bloc.tagsForArtist(widget.artist)),
              builder: (context, snapshots) {
                print(snapshots);

                List<Tag> allTags = snapshots.item1.hasData ? snapshots.item1.data : [];
                List<Tag> tagsForArtist = snapshots.item2.hasData ? snapshots.item2.data : [];

                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _buildTagChipsRow(context, widget.artist, allTags, tagsForArtist),
                );
              },
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
      )
    );
  }

  void _toggleEditMode() {
    setState(() {
      _tagEditMode = !_tagEditMode;
    });
  }

  List<Widget> _buildTagChipsRow(BuildContext context, Artist artist, List<Tag> allTags, List<Tag> tagsForArtist) {
    List<Tag> tagsToDisplay = _tagEditMode ? allTags : tagsForArtist;

    List<Widget> chipsList = tagsToDisplay.map(
      (tag) => _buildTagChip(context, artist, tag, tagsForArtist, (value) { })
    ).toList();
    if (_tagEditMode) {
      chipsList.add(_buildAddTagChip(context, artist));
    }
    return chipsList;
  }

  Widget _buildTagChip(BuildContext context, Artist artist, Tag tag, List<Tag> tagsForArtist, ValueChanged<Tag> onTapped) {
    return InputChip(
      label: Text(tag.name),
      selected: _tagEditMode && tagsForArtist.contains(tag),
      onPressed: () => _onTagChipPressed(artist, tag, tagsForArtist, onTapped)
    );
  }

  void _onTagChipPressed(Artist artist, Tag tag, List<Tag> tagsForArtist, ValueChanged<Tag> onTapped) async {
    if (_tagEditMode) {
      final bloc = Provider.of<MoodtagBloc>(context, listen: false);

      if (tagsForArtist.contains(tag)) {
        await bloc.removeTagFromArtist(artist, tag);
      } else {
        await bloc.assignTagToArtist(artist, tag);
      }
    } else {
      onTapped(tag);
    }
  }

  Widget _buildAddTagChip(BuildContext context, Artist artist) {
    return InputChip(
      label: Text('+'),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onPressed: () => AddEntityDialog.openAddTagDialog(context, preselectedArtist: artist)
    );
  }

}