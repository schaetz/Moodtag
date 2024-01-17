import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class CreateTagCategoryDialogForm extends StatefulWidget {
  late final bool isEditForm;
  late final String title;
  late final String? initialName;
  late final Color? initialColor;
  late final Function(String, Color) onSendInput;

  CreateTagCategoryDialogForm(
      {this.isEditForm = false, this.initialName, this.initialColor, required Function(String, Color) this.onSendInput})
      : title = isEditForm ? 'Edit tag category' : 'Create tag category';

  @override
  State<StatefulWidget> createState() => CreateTagCategoryDialogFormState();
}

class CreateTagCategoryDialogFormState extends State<CreateTagCategoryDialogForm> {
  String _nameInput = '';
  Color _colorInput = Colors.blue;
  late final TextEditingController _nameInputController;

  @override
  void initState() {
    super.initState();
    final initialName = widget.initialName ?? _nameInput;
    final initialColor = widget.initialColor ?? _colorInput;
    setState(() {
      _nameInput = initialName;
      _colorInput = initialColor;
      _nameInputController = new TextEditingController(text: initialName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(children: [
        TextField(
            controller: _nameInputController,
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
          onPressed: _nameInput.isNotEmpty ? () => _onOkayPressed() : null,
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
