import 'package:flutter/material.dart';

class RenameDialog extends StatefulWidget {
  final String currentName;
  final void Function(String newName) onNameChanged;

  RenameDialog({required this.currentName, required this.onNameChanged});

  @override
  _RenameDialogState createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.currentName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rename Asset Name'),
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(hintText: 'Enter new name'),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            String newName = _textEditingController.text.trim();
            widget.onNameChanged(newName);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
