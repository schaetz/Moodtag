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
    if (widget.suggestedEntities == null) {
      return _buildTextField(null, null);
    }

    return Autocomplete<String>(
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode,
              VoidCallback onFieldSubmitted) =>
          _buildTextField(textEditingController, focusNode),
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
      onSelected: (selectedValue) => _updateCurrentInput(selectedValue),
    );
  }

  Widget _buildTextField(TextEditingController? textEditingController, FocusNode? focusNode) => TextField(
      controller: textEditingController,
      focusNode: focusNode,
      maxLines: null,
      maxLength: 255,
      onChanged: (value) => _updateCurrentInput(value));

  void _updateCurrentInput(String value) => setState(() {
        _currentInput = value.trim();
      });
}
