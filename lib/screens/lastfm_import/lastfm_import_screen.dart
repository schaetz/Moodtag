import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moodtag/components/external_account_selector.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/dialogs/add_lastfm_account_dialog.dart';
import 'package:moodtag/utils/user_properties_index.dart';
import 'package:provider/provider.dart';

class LastfmImportScreen extends StatefulWidget {
  final String serviceName = 'Last.fm';

  @override
  State<StatefulWidget> createState() => _LastfmImportScreenState();
}

class _LastfmImportScreenState extends State<LastfmImportScreen> {
  MoodtagBloc bloc;
  StreamController<String> accountNameStreamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    bloc = Provider.of<MoodtagBloc>(context, listen: false);
    _updateAccountNameFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MtAppBar(context),
        body: Center(
          child: Column(
            children: [
              ExternalAccountSelector(
                serviceName: widget.serviceName,
                accountNameStreamController: accountNameStreamController,
                onAddAccountClick: () => _openSetAccountNameDialog(),
                onRemoveAccountClick: () => _setAccountName(null),
              )
            ],
          ),
        ));
  }

  void _updateAccountNameFromDatabase() {
    bloc
        .getUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME)
        .then((value) => accountNameStreamController.add(value));
  }

  void _openSetAccountNameDialog() async {
    String newAccountName = await AddExternalAccountDialog(context, widget.serviceName).show();
    if (newAccountName != null) {
      _setAccountName(newAccountName);
    }
  }

  void _setAccountName(String newAccountName) {
    if (bloc == null) {
      throw new Exception('${widget.serviceName} account name could not be set - BLoC object is not available');
    }

    bloc
        .createOrUpdateUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME, newAccountName)
        .whenComplete(() => _updateAccountNameFromDatabase());
  }
}
