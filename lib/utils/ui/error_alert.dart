import "package:flutter/material.dart";

class ErrorAlert extends StatelessWidget {
  static const okButtonKey = Key("okButton");

  const ErrorAlert({
    super.key,
    required this.error,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("An error occurred"),
      content: Text(error.toString()),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          key: okButtonKey,
          child: const Text("OK"),
        ),
      ],
    );
  }
}
