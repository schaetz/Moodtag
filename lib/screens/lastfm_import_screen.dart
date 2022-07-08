import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/dialogs/add_lastfm_account_dialog.dart';
import 'package:moodtag/utils/user_properties_index.dart';
import 'package:provider/provider.dart';

class LastfmImportScreen extends StatefulWidget {
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
    updateAccountNameFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MtAppBar(context),
        body: Center(
          child: Column(
            children: [
              StreamBuilder<String>(
                  stream: accountNameStreamController.stream,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return _accountNameContainer(snapshot.data);
                  }),
            ],
          ),
        ));
  }

  void updateAccountNameFromDatabase() {
    bloc
        .getUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME)
        .then((value) => accountNameStreamController.add(value));
  }

  Widget _accountNameContainer(String accountName) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(32.0),
      child: Column(children: [
        accountName == null
            ? Text('No associated account', style: TextStyle(fontStyle: FontStyle.italic))
            : Text(accountName),
        SizedBox(height: 16),
        _accountChangeButton(accountName != null),
      ]),
    );
  }

  Widget _accountChangeButton(bool hasAccountName) {
    if (!hasAccountName) {
      return ElevatedButton(
        onPressed: () => _openSetAccountNameDialog(),
        child: const Text('Add Last.fm account'),
      );
    } else {
      return ElevatedButton(
        onPressed: () => _setAccountName(null),
        child: const Text('Remove Last.fm account'),
      );
    }
  }

  void _openSetAccountNameDialog() async {
    String newAccountName = await AddLastFmAccountDialog(context).show();
    print(newAccountName);
    if (newAccountName != null) {
      _setAccountName(newAccountName);
    }
  }

  void _setAccountName(String newAccountName) {
    if (bloc == null) {
      throw new Exception('Last.fm account name could not be set - BLoC object is not available');
    }

    bloc
        .createOrUpdateUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME, newAccountName)
        .whenComplete(() => updateAccountNameFromDatabase());
  }
}
