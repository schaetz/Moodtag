import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodtag/exceptions/internal_exception.dart';
import 'package:moodtag/model/repository/repository.dart';

class ExternalAccountSelector extends StatelessWidget {
  late final Repository bloc;

  final DateFormat formatter = DateFormat('MM-dd-yyyy');

  final String serviceName;
  final String? accountName;
  final int? artistCount;
  final int? playCount;
  final DateTime? lastAccountUpdate;
  final DateTime? lastTopArtistsUpdate;
  final Function onAddAccountClick;
  final Function onRemoveAccountClick;
  final Function(Exception) onAddAccountError;
  final Function(Exception) onRemoveAccountError;

  ExternalAccountSelector({
    Key? key,
    required this.serviceName,
    required this.accountName,
    this.artistCount,
    this.playCount,
    this.lastAccountUpdate,
    this.lastTopArtistsUpdate,
    required this.onAddAccountClick,
    required this.onRemoveAccountClick,
    required this.onAddAccountError,
    required this.onRemoveAccountError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(32.0),
      child: Column(children: [
        accountName == null
            ? Text('No associated ${serviceName} account', style: TextStyle(fontStyle: FontStyle.italic))
            : Text(accountName!, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        if (artistCount != null) Text('Artists: ${artistCount!.toString()}'),
        if (playCount != null) Text('Play count: ${playCount!.toString()}'),
        if (lastAccountUpdate != null) Text('Last account update: ${formatter.format(lastAccountUpdate!)}'),
        if (lastTopArtistsUpdate != null) Text('Last top artists update: ${formatter.format(lastTopArtistsUpdate!)}'),
        _accountChangeButton(accountName != null),
      ]),
    );
  }

  Widget _accountChangeButton(bool hasAccountName) {
    if (!hasAccountName) {
      return ElevatedButton(
        onPressed: () => _addAccount(),
        child: Text('Add ${serviceName} account'),
      );
    } else {
      return ElevatedButton(
        onPressed: () => _removeAccount(),
        child: Text('Remove ${serviceName} account'),
      );
    }
  }

  void _addAccount() {
    try {
      onAddAccountClick();
    } catch (error) {
      onAddAccountError(InternalException('Something went wrong trying to set the ${serviceName} account.'));
    }
  }

  void _removeAccount() {
    try {
      onRemoveAccountClick();
    } catch (error) {
      onRemoveAccountError(
          InternalException('Something went wrong trying to remove the associated ${serviceName} account.'));
    }
  }
}
