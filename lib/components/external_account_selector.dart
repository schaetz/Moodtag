import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moodtag/database/moodtag_bloc.dart';
import 'package:moodtag/dialogs/add_lastfm_account_dialog.dart';
import 'package:moodtag/utils/user_properties_index.dart';
import 'package:provider/provider.dart';

class ExternalAccountSelector extends StatefulWidget {
  final String serviceName;

  const ExternalAccountSelector({Key key, this.serviceName}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExternalAccountSelectorState();
}

class _ExternalAccountSelectorState extends State<ExternalAccountSelector> {
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
    return StreamBuilder<String>(
        stream: accountNameStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return _accountNameContainer(snapshot.data);
        });
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
            ? Text('No associated ${this.widget.serviceName} account', style: TextStyle(fontStyle: FontStyle.italic))
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
        child: Text('Add ${this.widget.serviceName} account'),
      );
    } else {
      return ElevatedButton(
        onPressed: () => _setAccountName(null),
        child: Text('Remove ${this.widget.serviceName} account'),
      );
    }
  }

  void _openSetAccountNameDialog() async {
    String newAccountName = await AddExternalAccountDialog(context, this.widget.serviceName).show();
    if (newAccountName != null) {
      _setAccountName(newAccountName);
    }
  }

  void _setAccountName(String newAccountName) {
    if (bloc == null) {
      throw new Exception('${this.widget.serviceName} account name could not be set - BLoC object is not available');
    }

    bloc
        .createOrUpdateUserProperty(UserPropertiesIndex.USER_PROPERTY_LASTFM_ACCOUNT_NAME, newAccountName)
        .whenComplete(() => updateAccountNameFromDatabase());
  }
}
