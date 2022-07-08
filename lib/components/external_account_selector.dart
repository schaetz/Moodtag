import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moodtag/database/moodtag_bloc.dart';

class ExternalAccountSelector extends StatefulWidget {
  final String serviceName;
  final StreamController accountNameStreamController;
  final Function onAddAccountClick;
  final Function onRemoveAccountClick;

  const ExternalAccountSelector(
      {Key key, this.serviceName, this.accountNameStreamController, this.onAddAccountClick, this.onRemoveAccountClick})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExternalAccountSelectorState();
}

class _ExternalAccountSelectorState extends State<ExternalAccountSelector> {
  MoodtagBloc bloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: widget.accountNameStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return _accountNameContainer(snapshot.data);
        });
  }

  Widget _accountNameContainer(String accountName) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(32.0),
      child: Column(children: [
        accountName == null
            ? Text('No associated ${widget.serviceName} account', style: TextStyle(fontStyle: FontStyle.italic))
            : Text(accountName),
        SizedBox(height: 16),
        _accountChangeButton(accountName != null),
      ]),
    );
  }

  Widget _accountChangeButton(bool hasAccountName) {
    if (!hasAccountName) {
      return ElevatedButton(
        onPressed: () => widget.onAddAccountClick(),
        child: Text('Add ${widget.serviceName} account'),
      );
    } else {
      return ElevatedButton(
        onPressed: () => widget.onRemoveAccountClick(),
        child: Text('Remove ${widget.serviceName} account'),
      );
    }
  }
}
