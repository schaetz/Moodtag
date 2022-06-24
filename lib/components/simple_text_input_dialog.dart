import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleTextInputDialog extends StatelessWidget {
  final String message;
  final String confirmationButtonLabel;
  final Function(String) onSendInput;

  const SimpleTextInputDialog({Key key, this.message, this.confirmationButtonLabel, this.onSendInput})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var newInput;
    return SimpleDialog(
      title: Text(message),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(maxLines: null, maxLength: 255, onChanged: (value) => newInput = value.trim()),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    if (newInput == null || newInput.isEmpty) {
                      return;
                    }
                    onSendInput(newInput);
                  },
                  child: Text(confirmationButtonLabel),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
