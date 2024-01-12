import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/app/navigation/routes.dart';
import 'package:moodtag/features/app_settings/app_settings_bloc.dart';
import 'package:moodtag/features/app_settings/lastfm_account_management/lastfm_account_selector.dart';
import 'package:moodtag/features/import/spotify_import/auth/spotify_auth_bloc.dart';
import 'package:moodtag/model/repository/library_subscription/data_wrapper/loading_status.dart';
import 'package:moodtag/shared/bloc/events/lastfm_events.dart';
import 'package:moodtag/shared/bloc/events/library_events.dart';
import 'package:moodtag/shared/bloc/events/spotify_events.dart';
import 'package:moodtag/shared/dialogs/add_lastfm_account_dialog.dart';
import 'package:moodtag/shared/dialogs/delete_dialog.dart';
import 'package:moodtag/shared/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/shared/widgets/main_layout/mt_app_bar.dart';

class AppSettingsScreen extends StatelessWidget {
  static const headlineTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 22);
  final String serviceName = 'Last.fm';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppSettingsBloc>();
    return Scaffold(
        appBar: MtAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<AppSettingsBloc, AppSettingsState>(
              buildWhen: (previous, current) => current.lastFmAccountLoadingStatus == LoadingStatus.success,
              builder: (context, state) {
                return SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Import', style: headlineTextStyle),
                  _buildImportSection(context, bloc, state),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: Divider()),
                  Text('Library', style: headlineTextStyle),
                  _buildLibrarySection(context, bloc),
                ]));
              }),
        ));
  }

  Widget _buildImportSection(BuildContext context, AppSettingsBloc bloc, AppSettingsState state) {
    // TODO Why does the FractionallySizedBox not work as expected, but widthFactor=1 leads to the content being
    // centered while decreasing the widthFactor makes it move to the left?
    return FractionallySizedBox(
        widthFactor: 1,
        alignment: FractionalOffset.center,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          LastFmAccountSelector(
              serviceName: serviceName,
              accountName: state.lastFmAccount?.accountName,
              artistCount: state.lastFmAccount?.artistCount,
              playCount: state.lastFmAccount?.playCount,
              lastAccountUpdate: state.lastFmAccount?.lastAccountUpdate,
              lastTopArtistsUpdate: state.lastFmAccount?.lastTopArtistsUpdate,
              onAddAccountClick: () => _openSetLastFmAccountNameDialog(context, bloc),
              onRemoveAccountClick: () => bloc.add(RemoveLastFmAccount()),
              onUpdateAccountInfoClick: () => bloc.add(UpdateLastFmAccountInfo()),
              onAddAccountError: (e) => _handleAddLastFmAccountError(e, bloc),
              onRemoveAccountError: (e) => _handleRemoveLastFmAccountError(e, bloc),
              onUpdateAccountInfoError: (e) => _handleUpdateLastFmAccountInfoError(e, bloc)),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                  child: Text('Import from Last.fm'),
                  onPressed: bloc.state.hasAccount ? () => _showLastFmImportScreen(context) : null)),
          Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                  child: Text('Import from Spotify'), onPressed: () => _showSpotifyImportScreen(context)))
        ]));
  }

  Widget _buildLibrarySection(BuildContext context, AppSettingsBloc bloc) {
    return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(children: [
          Center(
              child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: ElevatedButton(
                      child: Text('Reset library'), onPressed: () => _showResetLibraryDialog(context, bloc))))
        ]));
  }

  void _showLastFmImportScreen(BuildContext context) => Navigator.of(context).pushNamed(Routes.lastFmImport);

  void _openSetLastFmAccountNameDialog(BuildContext context, AppSettingsBloc bloc) async {
    AddExternalAccountDialog(context, serviceName, onTerminate: (newAccountName) {
      if (newAccountName != null) {
        bloc.add(AddLastFmAccount(newAccountName));
      }
    });
  }

  void _handleAddLastFmAccountError(Exception e, AppSettingsBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to set the ${serviceName} account.", cause: e));
  }

  void _handleRemoveLastFmAccountError(Exception e, AppSettingsBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to remove the ${serviceName} account.", cause: e));
  }

  void _handleUpdateLastFmAccountInfoError(Exception e, AppSettingsBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to update the ${serviceName} account info.", cause: e));
  }

  void _showSpotifyImportScreen(BuildContext context) {
    if (context.read<SpotifyAuthBloc>().state.spotifyAuthCode == null) {
      Function redirectAfterAuth = () {
        Navigator.pop(context);
        Navigator.pushNamed(context, Routes.spotifyImport);
      };
      context.read<SpotifyAuthBloc>().add(RequestUserAuthorization(redirectAfterAuth: redirectAfterAuth));
      Navigator.of(context).pushNamed(Routes.spotifyAuth);
    } else {
      Navigator.of(context).pushNamed(Routes.spotifyImport);
    }
  }

  void _showResetLibraryDialog(BuildContext context, AppSettingsBloc bloc) {
    DeleteDialog.openNew(context,
        deleteHandler: () => bloc.add(ResetLibrary()), entityToDelete: null, resetLibrary: true);
  }
}
