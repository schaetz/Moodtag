import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/components/import_config_form.dart';
import 'package:moodtag/components/mt_app_bar.dart';

import 'import_flow_state.dart';

enum SpotifyImportOption { topArtists, followedArtists, artistGenres }

class SpotifyImportConfigScreen extends StatelessWidget {
  final Function(Map<SpotifyImportOption, bool>) onConfirmConfig;

  const SpotifyImportConfigScreen({Key? key, required this.onConfirmConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MtAppBar(context, onBackButtonPressed: () => context.flow<ImportFlowState>().complete()),
      body: Center(
          child: ImportConfigForm(
        headlineCaption: 'Select what should be imported:',
        sendButtonCaption: 'Start Spotify Import',
        configItemsWithCaption: _getConfigItemsWithCaption(),
        onSend: _confirmImportConfiguration,
      )),
    );
  }

  Map<String, String> _getConfigItemsWithCaption() {
    final Map<String, String> configItemsWithCaption = {
      SpotifyImportOption.topArtists.name: 'Top artists',
      SpotifyImportOption.followedArtists.name: 'Followed artists',
      SpotifyImportOption.artistGenres.name: 'Artist genres'
    };
    return configItemsWithCaption;
  }

  void _confirmImportConfiguration(BuildContext context, Map<String, bool> selectedOptions) async {
    final Map<SpotifyImportOption, bool> configItemsWithSelection = {
      SpotifyImportOption.topArtists: selectedOptions[SpotifyImportOption.topArtists.name] ?? false,
      SpotifyImportOption.followedArtists: selectedOptions[SpotifyImportOption.followedArtists.name] ?? false,
      SpotifyImportOption.artistGenres: selectedOptions[SpotifyImportOption.artistGenres.name] ?? false,
    };
    onConfirmConfig(configItemsWithSelection);
  }
}
