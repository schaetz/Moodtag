import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moodtag/components/external_account_selector.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_lastfm_account_dialog.dart';
import 'package:moodtag/exceptions/unknown_error.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_bloc.dart';
import 'package:moodtag/model/blocs/lastfm_import/lastfm_import_state.dart';
import 'package:moodtag/model/blocs/loading_status.dart';
import 'package:moodtag/model/events/lastfm_events.dart';

class LastfmImportScreen extends StatelessWidget {
  final String serviceName = 'Last.fm';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LastFmImportBloc>();
    return Scaffold(
        appBar: MtAppBar(context),
        body: Center(
          child: Column(
            children: [
              BlocBuilder<LastFmImportBloc, LastFmImportState>(
                  buildWhen: (previous, current) => current.accountNameLoadingStatus == LoadingStatus.success,
                  builder: (context, state) {
                    return ExternalAccountSelector(
                      serviceName: serviceName,
                      accountName: state.accountName,
                      onAddAccountClick: () => _openSetAccountNameDialog(context, bloc),
                      onRemoveAccountClick: () => bloc.add(RemoveLastFmAccount()),
                      onAddAccountError: (e) => _handleAddAccountError(e, bloc),
                      onRemoveAccountError: (e) => _handleRemoveAccountError(e, bloc),
                    );
                  }),
            ],
          ),
        ));
  }

  void _openSetAccountNameDialog(BuildContext context, LastFmImportBloc bloc) async {
    AddExternalAccountDialog(context, serviceName, onTerminate: (newAccountName) {
      if (newAccountName != null) {
        bloc.add(AddLastFmAccount(newAccountName));
      }
    });
  }

  void _handleAddAccountError(Exception e, LastFmImportBloc bloc) {
    bloc.errorStreamController.add(UnknownError("Something went wrong trying to set the ${serviceName} account."));
  }

  void _handleRemoveAccountError(Exception e, LastFmImportBloc bloc) {
    bloc.errorStreamController.add(UnknownError("Something went wrong trying to remove the ${serviceName} account."));
  }
}
