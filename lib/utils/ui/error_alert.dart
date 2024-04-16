import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class ExceptionAlert extends StatelessWidget {
  const ExceptionAlert({
    super.key,
    required this.exception,
  });

  final Exception exception;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("An error occurred"),
      content: Text(exception.toString()),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
