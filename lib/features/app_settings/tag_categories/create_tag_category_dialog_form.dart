import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class CreateTagCategoryDialogForm extends StatefulWidget {
  late final Function(String, Color) onSendInput;

  CreateTagCategoryDialogForm({required Function(String, Color) this.onSendInput});

  @override
  State<StatefulWidget> createState() => CreateTagCategoryDialogFormState();
}

class CreateTagCategoryDialogFormState extends State<CreateTagCategoryDialogForm> {
  String _nameInput = '';
  Color _colorInput = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create tag category'),
      content: Column(children: [
        TextField(
            decoration: InputDecoration(label: const Text('Name')),
            maxLines: null,
            maxLength: 30,
            onChanged: (value) => setState(() {
                  _nameInput = value;
                })),
        ColorPicker(
            color: _colorInput,
            onColorChanged: (Color value) => setState(() {
                  _colorInput = value;
                }))
      ]),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _onOkayPressed(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _onOkayPressed() {
    widget.onSendInput(_nameInput, _colorInput);
    Navigator.pop(context, 'OK');
  }
}
