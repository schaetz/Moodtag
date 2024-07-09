import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moodtag/features/import/abstract_import_flow/config/abstract_import_config.dart';
import 'package:moodtag/shared/widgets/data_display/data_list.dart';
import 'package:moodtag/shared/widgets/import/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';

abstract class AbstractImportConfirmationScreen extends StatelessWidget {
  // TODO Use common property with list screens?
  static const headlineStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  static const listEntryStyle = TextStyle(fontSize: 18.0);

  final ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory;

  AbstractImportConfirmationScreen({super.key, required this.scaffoldBodyWrapperFactory});

  Widget getImportedEntitiesOverviewList(
      Map<String, int> entityFrequencies, AbstractImportConfig importConfig, bool showTagCategory) {
    final Map<String, String> settingsData =
        showTagCategory ? {'Tag category:': importConfig.categoryForTags?.name ?? ''} : {};
    settingsData.putIfAbsent('Initial tag:', () => importConfig.initialTagForArtists?.name ?? '');

    return Column(children: [
      DataList<int>(headline: 'Entities to import:', data: entityFrequencies),
      DataList<String>(headline: 'Settings:', data: settingsData),
    ]);
  }
}
