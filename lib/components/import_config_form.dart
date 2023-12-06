import 'package:flutter/material.dart';

class ImportConfigForm extends StatefulWidget {
  final String headlineCaption;
  final String sendButtonCaption;
  final Map<String, String> configItemsWithCaption;
  final Map<String, bool> initialConfig;
  final Function(Map<String, bool>) onChangeSelection;

  const ImportConfigForm({
    Key? key,
    required this.headlineCaption,
    required this.sendButtonCaption,
    required this.configItemsWithCaption,
    required this.initialConfig,
    required this.onChangeSelection,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImportConfigFormState();
}

class _ImportConfigFormState extends State<ImportConfigForm> {
  static const headlineStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

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
              child: Text(this.widget.headlineCaption, style: headlineStyle),
            )),
        ...this.widget.configItemsWithCaption.entries.map((keyAndCaption) => CheckboxListTile(
              title: Text(keyAndCaption.value),
              value: _selectionsState[keyAndCaption.key],
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectionsState[keyAndCaption.key] = newValue;
                  });
                  widget.onChangeSelection(_selectionsState);
                }
              },
            )),
      ],
    );
  }

  void _initializeSelectionsState() {
    this._selectionsState = {};
    widget.configItemsWithCaption.entries.forEach(
        (keyAndCaption) => this._selectionsState[keyAndCaption.key] = widget.initialConfig[keyAndCaption.key] ?? false);
  }
}
