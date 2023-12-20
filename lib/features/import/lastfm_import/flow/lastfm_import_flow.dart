import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/app_bar_context_data.dart';
import 'package:moodtag/features/import/abstract_import_flow/flow/abstract_import_flow.dart';
import 'package:moodtag/features/import/import_selection_list/import_selection_list_screen.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_bloc.dart';
import 'package:moodtag/features/import/lastfm_import/bloc/lastfm_import_state.dart';
import 'package:moodtag/features/import/lastfm_import/config/lastfm_import_period.dart';
import 'package:moodtag/features/import/lastfm_import/flow/lastfm_import_flow_step.dart';
import 'package:moodtag/model/events/lastfm_import_events.dart';
import 'package:moodtag/navigation/routes.dart';
import 'package:moodtag/shared/models/structs/imported_entities/lastfm_artist.dart';
import 'package:moodtag/shared/utils/i10n.dart';
import 'package:provider/provider.dart';

import '../steps/lastfm_import_config_screen.dart';
import '../steps/lastfm_import_confirmation_screen.dart';
import 'lastfm_import_flow_state.dart';

class LastFmImportFlow extends AbstractImportFlow {
  LastFmImportFlow() : super('Last.fm Import', LastFmImportFlowStep.values.length);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LastFmImportBloc>();
    return BlocConsumer<LastFmImportBloc, LastFmImportState>(listener: (context, state) {
      if (state.isFinished) {
        returnToLibraryScreens(context);
      }
    }, builder: (context, state) {
      return Provider(
          create: (_) => AppBarContextData(
              onBackButtonPressed: () => onBackButtonPressed(context, bloc, LastFmImportFlowStep.config.index)),
          child: FlowBuilder<LastFmImportFlowState>(
            state: LastFmImportFlowState(step: state.step),
            onGeneratePages: (LastFmImportFlowState importFlowState, List<Page> pages) =>
                onGenerateImportFlowPages(importFlowState, pages, bloc),
          ));
    });
  }

  List<Page> onGenerateImportFlowPages(LastFmImportFlowState importFlowState, List<Page> pages, LastFmImportBloc bloc) {
    final List<LastFmImportFlowStep> flowStepsTillCurrentStep =
        LastFmImportFlowStep.values.where((step) => importFlowState.step.index >= step.index).toList();

    return flowStepsTillCurrentStep
        .map((step) => createMaterialPageForImportStep(step.index,
            screen: _getScreenForFlowStep(bloc, step), route: Routes.lastFmImport))
        .toList();
  }

  Widget _getScreenForFlowStep(LastFmImportBloc bloc, LastFmImportFlowStep step) {
    switch (step) {
      case LastFmImportFlowStep.config:
        return LastFmImportConfigScreen(
            scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index));
      case LastFmImportFlowStep.artistsSelection:
        return _getArtistsSelectionScreen(bloc);
      case LastFmImportFlowStep.confirmation:
        return LastFmImportConfirmationScreen(
            scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index));
    }
  }

  Widget _getArtistsSelectionScreen(LastFmImportBloc bloc) {
    return ImportSelectionListScreen<LastFmArtist>(
      scaffoldBodyWrapperFactory: getImportFlowScreenWrapperFactory(bloc.state.step.index),
      namedEntitySet: bloc.state.availableLastFmArtists!,
      confirmationButtonLabel: "OK",
      entityDenotationSingular: I10n.ARTIST_DENOTATION_SINGULAR,
      entityDenotationPlural: I10n.ARTIST_DENOTATION_PLURAL,
      onSelectionConfirmed: (List<LastFmArtist> selectedArtists) =>
          bloc.add(ConfirmLastFmArtistsForImport(selectedArtists)),
      getSubtitleText: (LastFmArtist artist) => _getPlayCountSubtitleForArtist(artist),
      subtitleIcon: Icons.headphones,
    );
  }

  String? _getPlayCountSubtitleForArtist(LastFmArtist artist) {
    if (artist.playCounts.isEmpty) {
      return null;
    }

    final longestPeriod = artist.playCounts.keys.first;
    final playCountString = artist.playCounts[longestPeriod].toString();

    if (longestPeriod != LastFmImportPeriod.overall) {
      final periodString = longestPeriod.humanReadableString;
      return '$playCountString ($periodString)';
    }

    return playCountString;
  }
}
