import 'package:flutter/material.dart';
class EditTodoDialog extends StatelessWidget {
  final TextEditingController _controller;

  EditTodoDialog({required String initialTitle})
      : _controller = TextEditingController(text: initialTitle);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Todo'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: "Enter new title"),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}