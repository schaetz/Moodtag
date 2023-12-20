import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_lastfm_account_dialog.dart';
import 'package:moodtag/exceptions/user_readable/unknown_error.dart';
import 'package:moodtag/features/import/lastfm_account_management/lastfm_account_management_bloc.dart';
import 'package:moodtag/features/import/lastfm_account_management/lastfm_account_management_state.dart';
import 'package:moodtag/model/events/lastfm_events.dart';
import 'package:moodtag/model/repository/loading_status.dart';
import 'package:moodtag/navigation/routes.dart';

import 'lastfm_account_selector.dart';

class LastFmAccountManagementScreen extends StatelessWidget {
  final String serviceName = 'Last.fm';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LastFmAccountManagementBloc>();
    return Scaffold(
        appBar: MtAppBar(context),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<LastFmAccountManagementBloc, LastFmAccountManagementState>(
              buildWhen: (previous, current) => current.accountLoadingStatus == LoadingStatus.success,
              builder: (context, state) {
                return ListView(children: [
                  LastFmAccountSelector(
                      serviceName: serviceName,
                      accountName: state.lastFmAccount?.accountName,
                      artistCount: state.lastFmAccount?.artistCount,
                      playCount: state.lastFmAccount?.playCount,
                      lastAccountUpdate: _getDateTimeFromTimestamp(state.lastFmAccount?.lastAccountUpdate),
                      lastTopArtistsUpdate: _getDateTimeFromTimestamp(state.lastFmAccount?.lastTopArtistsUpdate),
                      onAddAccountClick: () => _openSetAccountNameDialog(context, bloc),
                      onRemoveAccountClick: () => bloc.add(RemoveLastFmAccount()),
                      onUpdateAccountInfoClick: () => bloc.add(UpdateLastFmAccountInfo()),
                      onAddAccountError: (e) => _handleAddAccountError(e, bloc),
                      onRemoveAccountError: (e) => _handleRemoveAccountError(e, bloc),
                      onUpdateAccountInfoError: (e) => _handleUpdateAccountInfoError(e, bloc)),
                  ElevatedButton(
                      child: Text('Import from Last.fm'),
                      onPressed: bloc.state.hasAccount ? () => _showImportFlowScreen(context) : null),
                ]);
              }),
        )));
  }

  void _showImportFlowScreen(BuildContext context) => Navigator.of(context).pushNamed(Routes.lastFmImport);

  DateTime? _getDateTimeFromTimestamp(double? timestamp) {
    if (timestamp == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp.round(), isUtc: true);
  }

  void _openSetAccountNameDialog(BuildContext context, LastFmAccountManagementBloc bloc) async {
    AddExternalAccountDialog(context, serviceName, onTerminate: (newAccountName) {
      if (newAccountName != null) {
        bloc.add(AddLastFmAccount(newAccountName));
      }
    });
  }

  void _handleAddAccountError(Exception e, LastFmAccountManagementBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to set the ${serviceName} account.", cause: e));
  }

  void _handleRemoveAccountError(Exception e, LastFmAccountManagementBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to remove the ${serviceName} account.", cause: e));
  }

  void _handleUpdateAccountInfoError(Exception e, LastFmAccountManagementBloc bloc) {
    bloc.errorStreamController
        .add(UnknownError("Something went wrong trying to update the ${serviceName} account info.", cause: e));
  }
}
