import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;

  const ErrorDialog( this.errorMessage, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('There was an Error'),
      content:
      SingleChildScrollView(
        child: Column(
          children: [
            Text(errorMessage),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
