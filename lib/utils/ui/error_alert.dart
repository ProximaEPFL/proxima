import "package:flutter/material.dart";

/// A simple alert dialog that displays an error message.
class ErrorAlert extends StatelessWidget {
  static const okButtonKey = Key("okButton");

  /// Constructor for the [ErrorAlert] widget.
  /// [error] is the error object to display.
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
