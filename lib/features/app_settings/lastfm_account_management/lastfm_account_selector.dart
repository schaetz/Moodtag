import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodtag/shared/exceptions/internal/internal_exception.dart';

class LastFmAccountSelector extends StatelessWidget {
  static const accountNameTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  final DateFormat formatter = DateFormat('MM-dd-yyyy');

  final String serviceName;
  final String? accountName;
  final int? artistCount;
  final int? playCount;
  final DateTime? lastAccountUpdate;
  final DateTime? lastTopArtistsUpdate;
  final Function onAddAccountClick;
  final Function onRemoveAccountClick;
  final Function onUpdateAccountInfoClick;
  final Function onImportClick;
  final Function(Exception) onAddAccountError;
  final Function(Exception) onRemoveAccountError;
  final Function(Exception) onUpdateAccountInfoError;

  LastFmAccountSelector({
    Key? key,
    required this.serviceName,
    required this.accountName,
    this.artistCount,
    this.playCount,
    this.lastAccountUpdate,
    this.lastTopArtistsUpdate,
    required this.onAddAccountClick,
    required this.onRemoveAccountClick,
    required this.onUpdateAccountInfoClick,
    required this.onImportClick,
    required this.onAddAccountError,
    required this.onRemoveAccountError,
    required this.onUpdateAccountInfoError,
  }) : super(key: key);

  bool get hasAccountName => accountName != null;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      color: Theme.of(context).colorScheme.secondary, // TODO The color should not have to be specified here
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            hasAccountName
                ? Text(accountName!, style: accountNameTextStyle)
                : Text('No associated ${serviceName} account', style: TextStyle(fontStyle: FontStyle.italic)),
            SizedBox(height: 16),
            ..._accountInfo(),
            _accountChangeButton(),
            if (hasAccountName) _updateAccountInfoButton(),
            ElevatedButton(child: Text('Import from Last.fm'), onPressed: onImportClick()),
          ])),
    ));
  }

  Widget _accountChangeButton() {
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

  List<Widget> _accountInfo() {
    final List<Widget> accountInfoWidgets = [
      if (artistCount != null) Text('Artists: ${artistCount!.toString()}'),
      if (playCount != null) Text('Play count: ${playCount!.toString()}'),
      if (lastAccountUpdate != null) Text('Last account update: ${formatter.format(lastAccountUpdate!)}'),
      if (lastTopArtistsUpdate != null) Text('Last top artists update: ${formatter.format(lastTopArtistsUpdate!)}')
    ];
    return accountInfoWidgets;
  }

  Widget _updateAccountInfoButton() {
    return ElevatedButton(onPressed: () => _updateAccountInfo(), child: Text('Update account info'));
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

  void _updateAccountInfo() {
    try {
      onUpdateAccountInfoClick();
    } catch (error) {
      onUpdateAccountInfoError(
          InternalException('Something went wrong trying to remove the associated ${serviceName} account.'));
    }
  }
}
