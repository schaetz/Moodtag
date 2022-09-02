import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_entity_dialog.dart';
import 'package:moodtag/model/bloc/artists/artists_bloc.dart';
import 'package:moodtag/model/database/moodtag_db.dart';
import 'package:moodtag/model/repository.dart';
import 'package:provider/provider.dart';

import '../model/bloc/artists/artists_state.dart';

class ArtistDetailsScreen extends StatefulWidget {
  final Artist artist;

  static const artistNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  ArtistDetailsScreen(BuildContext context) : artist = ModalRoute.of(context).settings.arguments as Artist;

  @override
  State<StatefulWidget> createState() => _ArtistDetailsScreenState();
}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen> {
  bool _tagEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MtAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(widget.artist.name, style: ArtistDetailsScreen.artistNameStyle),
            ),
            BlocBuilder<ArtistsBloc, ArtistsState>(
              buildWhen: (previous, current) => current.status.isSuccess,
              builder: (context, state) {
                return _buildTagChipsRow(context, widget.artist, state.tagsWithSelectedArtist);
              },
            ),
            Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: ElevatedButton(
                    child: Text(_tagEditMode ? 'Finish editing' : 'Edit tags'), onPressed: () => _toggleEditMode()))
          ]),
        ));
  }

  void _toggleEditMode() {
    setState(() {
      _tagEditMode = !_tagEditMode;
    });
  }

  Widget _buildTagChipsRow(BuildContext context, Artist artist, List<Tag> tagsForArtist) {
    List<Tag> tagsToDisplay = tagsForArtist; // TODO Display all tags in tag edit mode

    List<Widget> chipsList =
        tagsToDisplay.map((tag) => _buildTagChip(context, artist, tag, tagsForArtist, (value) {})).toList();
    if (_tagEditMode) {
      chipsList.add(_buildAddTagChip(context, artist));
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: chipsList,
    );
  }

  Widget _buildTagChip(
      BuildContext context, Artist artist, Tag tag, List<Tag> tagsForArtist, ValueChanged<Tag> onTapped) {
    return InputChip(
        label: Text(tag.name),
        selected: _tagEditMode && tagsForArtist.contains(tag),
        onPressed: () => _onTagChipPressed(artist, tag, tagsForArtist, onTapped));
  }

  void _onTagChipPressed(Artist artist, Tag tag, List<Tag> tagsForArtist, ValueChanged<Tag> onTapped) async {
    if (_tagEditMode) {
      final bloc = Provider.of<Repository>(context, listen: false);

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
        onPressed: () => AddEntityDialog.openAddTagDialog(context, preselectedArtist: artist));
  }
}
