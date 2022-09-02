import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moodtag/components/external_account_selector.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/model/repository.dart';
import 'package:moodtag/dialogs/add_lastfm_account_dialog.dart';
import 'package:moodtag/screens/lastfm_import/lastfm_connector.dart';
import 'package:moodtag/utils/user_properties_index.dart';
import 'package:provider/provider.dart';

class LastfmImportScreen extends StatefulWidget {
  final String serviceName = 'Last.fm';

  @override
  State<StatefulWidget> createState() => _LastfmImportScreenState();
}

class _LastfmImportScreenState extends State<LastfmImportScreen> {
  Repository bloc;
  StreamController<String> accountNameStreamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    bloc = Provider.of<Repository>(context, listen: false);
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
                onAddAccountClick: () => _openSetAccountNameDialog(context),
                onRemoveAccountClick: () => _removeAccountName(),
              )
            ],
          ),
        ));
  }

  void _updateAccountNameFromDatabase() => bloc
      .getUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME)
      .then((value) => accountNameStreamController.add(value));

  void _openSetAccountNameDialog(BuildContext context) async {
    String newAccountName = await AddExternalAccountDialog(context, widget.serviceName).show();
    if (newAccountName != null) {
      _setAccountName(newAccountName);
    }
  }

  // TODO Error handling
  void _setAccountName(String newAccountName) async {
    final userInfo = await getUserInfo(newAccountName).onError((error, stackTrace) => throw error);
    print(userInfo); // TODO Can be removed

    bloc
        .createOrUpdateUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME, newAccountName)
        .then((_) => _updateAccountNameFromDatabase());
  }

  void _removeAccountName() {
    bloc
        .deleteUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME)
        .then((_) => _updateAccountNameFromDatabase());
  }
}
