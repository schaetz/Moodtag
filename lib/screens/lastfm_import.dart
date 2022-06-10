import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moodtag/components/mt_app_bar.dart';
import 'package:moodtag/dialogs/add_lastfm_account_dialog.dart';

class LastfmImportScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _LastfmImportScreenState();

}

class _LastfmImportScreenState extends State<LastfmImportScreen> {

  String _accountName = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MtAppBar(context),
        body: Center(
          child: Column(
            children: [
              _accountNameContainer(),
            ],
          ),
        )
    );
  }

  Widget _accountNameContainer() {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          _accountName == null ? Text('No associated account', style: TextStyle(fontStyle: FontStyle.italic))
                               : Text(_accountName),
          SizedBox(height: 16),
          _accountChangeButton(),
        ]
      ),
    );
  }

  Widget _accountChangeButton() {
    if (_accountName == null) {
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
    _accountName = newAccountName;
    print(_accountName);
  }

}
