import 'package:flutter/material.dart';

class ImportConfigForm extends StatefulWidget {
  final String headlineCaption;
  final String sendButtonCaption;
  final Map<String, String> configItemsWithCaption;
  final Function(BuildContext, Map<String, bool>) onSend;

  const ImportConfigForm(
      {Key? key,
      required this.headlineCaption,
      required this.sendButtonCaption,
      required this.configItemsWithCaption,
      required this.onSend})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImportConfigFormState();
}

class _ImportConfigFormState extends State<ImportConfigForm> {
  late final Map<String, bool> _selectionsState;

  @override
  void initState() {
    super.initState();
    _initializeSelectionsState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
              child: Text(this.widget.headlineCaption),
            )),
        ...this.widget.configItemsWithCaption.entries.map((keyAndCaption) => CheckboxListTile(
              title: Text(keyAndCaption.value),
              value: _selectionsState[keyAndCaption.key],
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectionsState[keyAndCaption.key] = newValue;
                  });
                }
              },
            )),
        TextButton(
          onPressed: _isButtonEnabled() ? () => this.widget.onSend(context, _selectionsState) : null,
          child: Text(this.widget.sendButtonCaption),
        ),
      ],
    );
  }

  bool _isButtonEnabled() => _selectionsState.values.contains(true);

  void _initializeSelectionsState() {
    this._selectionsState = {};
    this
        .widget
        .configItemsWithCaption
        .entries
        .forEach((keyAndCaption) => {this._selectionsState[keyAndCaption.key] = false});
  }
}
