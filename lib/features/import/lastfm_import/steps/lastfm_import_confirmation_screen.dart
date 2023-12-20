import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/features/import/abstract_import_flow/steps/abstract_import_confirmation_screen.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_bloc.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_state.dart';
import 'package:moodtag/shared/bloc/events/lastfm_import_events.dart';
import 'package:moodtag/shared/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/shared/widgets/import/scaffold_body_wrapper/scaffold_body_wrapper_factory.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_app_bar.dart';

class LastFmImportConfirmationScreen extends AbstractImportConfirmationScreen {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  LastFmImportConfirmationScreen({Key? key, required ScaffoldBodyWrapperFactory scaffoldBodyWrapperFactory})
      : super(key: key, scaffoldBodyWrapperFactory: scaffoldBodyWrapperFactory);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LastFmImportBloc>();
    return Scaffold(
        key: scaffoldKey,
        appBar: MtAppBar(context),
        body: scaffoldBodyWrapperFactory.create(
            bodyWidget: Center(child: BlocBuilder<LastFmImportBloc, LastFmImportState>(builder: (context, state) {
          return getImportedEntitiesOverviewList(_getEntityFrequencies(state));
        }))),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (bloc.state.selectedArtists != null) {
              bloc.add(CompleteLastFmImport(bloc.state.selectedArtists!));
            } else {
              bloc.errorStreamController.add(UnknownError('Something went wrong.'));
            }
          },
          label: Text('Import'),
          icon: const Icon(Icons.library_add),
        ));
  }

  Map<String, int> _getEntityFrequencies(LastFmImportState state) {
    final Map<String, int> entityFreq = {};
    if (state.selectedArtists != null && state.selectedArtists!.isNotEmpty) {
      entityFreq.putIfAbsent('Artists', () => state.selectedArtists!.length);
    }
    return entityFreq;
  }
}
