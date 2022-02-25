import 'package:flutter/material.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/structs/import_artists_arguments.dart';
import 'package:moodtag/utils/db_request_success_counter.dart';
import 'package:provider/provider.dart';

class ImportArtistsListScreen extends StatefulWidget {

  @override
  State<ImportArtistsListScreen> createState() => _ImportArtistsListScreenState();

}


class _ImportArtistsListScreenState extends State<ImportArtistsListScreen> {

  static const listEntryStyle = TextStyle(fontSize: 18.0);

  List<bool> _isBoxSelected;
  int _selectedBoxesCount;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as ImportArtistsArguments;
    final List<String> artists = args.artists.toList();
    artists.sort();

    if (_isBoxSelected == null) {
      _setBoxSelections(artists.length, true);
    }

    return Scaffold(
      appBar: MtAppBar(context),
      body: ListView.separated(
        separatorBuilder: (context, _) => Divider(),
        padding: EdgeInsets.all(16.0),
        itemCount: artists.length,
        itemBuilder: (context, i) {
          return _buildArtistRow(context, artists[i], i);
        },
      ),
      floatingActionButton: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 32),
              child: _buildFloatingSelectButton(context, artists.length),
            ),
            FloatingActionButton.extended(
              onPressed: () => _onImportButtonPressed(context, artists),
              label: const Text('Import'),
              icon: const Icon(Icons.add_circle_outline),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              heroTag: 'import_button',
            ),
          //add right Widget here with padding right
          ],
        ),
      ),
    );
  }
  
  void _setBoxSelections(int artistsCount, bool value) {
    setState(() {
      _isBoxSelected = List.filled(artistsCount, value);
      _selectedBoxesCount = value == true ? artistsCount : 0;
    });
  }

  Widget _buildArtistRow(BuildContext context, String artistName, int index) {
    return CheckboxListTile(
      title: Text(
        artistName,
        style: listEntryStyle,
      ),
      value: _isBoxSelected[index],
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool newValue) {
        setState(() {
          _isBoxSelected[index] = newValue;
          if (newValue == true) {
            _selectedBoxesCount++;
          } else {
            _selectedBoxesCount--;
          }
        });
      }
    );
  }

  void _onImportButtonPressed(BuildContext context, List<String> artistsNames) async {
    final bloc = Provider.of<MoodtagBloc>(context, listen: false);
    final requestSuccessCounter = new DbRequestSuccessCounter();

    for (int i=0 ; i < artistsNames.length; i++){
      if (_isBoxSelected[i]) {
        String newArtistName = artistsNames[i];
        final createArtistResponse = await bloc.createArtist(newArtistName);
        requestSuccessCounter.registerResponse(createArtistResponse);
      }
    }

    if (requestSuccessCounter.totalCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("No artists selected for import.")
          )
      );
    } else {
      final successMessage = requestSuccessCounter.successCount == requestSuccessCounter.totalCount
        ? "Successfully added ${requestSuccessCounter.successCount} selected artists."
        : "Successfully added ${requestSuccessCounter.successCount} "
          + "out of ${requestSuccessCounter.totalCount} selected artists.";

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage))
      );

      Navigator.of(context).popUntil(ModalRouteExt.withNames(Routes.artistsList, Routes.tagsList));
    }
  }

  Widget _buildFloatingSelectButton(BuildContext context, int artistsCount) {
    if (_selectedBoxesCount == artistsCount) {
      return FloatingActionButton.extended(
        onPressed: () => _setBoxSelections(artistsCount, false),
        label: const Text('Select none'),
        icon: const Icon(Icons.remove_circle_outline),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        heroTag: 'select_button',
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () => _setBoxSelections(artistsCount, true),
        label: const Text('Select all'),
        icon: const Icon(Icons.select_all_outlined),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        heroTag: 'select_button',
      );
    }
  }

}