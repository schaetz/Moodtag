import 'package:flutter/material.dart';
import 'package:moodtag/model/database/join_data_classes.dart';
import 'package:moodtag/shared/models/structs/named_entity.dart';

class SimpleTextInputDialogBase extends StatefulWidget {
  final String message;
  final String confirmationButtonLabel;
  final Function(String) onSendInput;
  final List<NamedEntity>? suggestedEntities;

  const SimpleTextInputDialogBase(
      {Key? key,
      required this.message,
      required this.confirmationButtonLabel,
      required this.onSendInput,
      this.suggestedEntities = null})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SimpleTextInputDialogBaseState();
}

class SimpleTextInputDialogBaseState extends State<SimpleTextInputDialogBase> {
  String _currentInput = '';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(widget.message),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildTextInput(context),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: () {
                    if (_currentInput.isEmpty) {
                      return;
                    }
                    widget.onSendInput(_currentInput);
                  },
                  child: Text(widget.confirmationButtonLabel),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTextInput(BuildContext context) {
    if (widget.suggestedEntities != null) {
      print(widget.suggestedEntities!.map((e) => e.name));
      return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }

          final trimmedTextEditingValue = textEditingValue.text.toLowerCase().trim();
          return widget.suggestedEntities!.where((NamedEntity option) {
            final optionName = option.name.toLowerCase();
            final optionOrderingName = option is DataClassWithEntityName ? option.orderingName : optionName;
            return optionName.startsWith(trimmedTextEditingValue) ||
                optionOrderingName.startsWith(trimmedTextEditingValue);
          }).map((matchingEntity) => matchingEntity.name);
        },
      );
    }

    return TextField(
        maxLines: null,
        maxLength: 255,
        onChanged: (value) => setState(() {
              _currentInput = value.trim();
            }));
  }
}
