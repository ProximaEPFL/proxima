import "package:flutter/material.dart";

/// A simple alert dialog that displays the offline error message.
/// Used by the circular value when the future times out.
class OfflineAlert extends StatelessWidget {
  static const okButtonKey = Key("offlineAlertOkButton");

  static const errorMessage =
      "Your device is offline or has poor internet connectivity.\nTry again later.";

  /// Constructor for the [OfflineAlert] widget.
  const OfflineAlert({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final okButton = TextButton(
      onPressed: Navigator.of(context).pop,
      key: okButtonKey,
      child: const Text("OK"),
    );

    return AlertDialog(
      title: const Text("Device offline"),
      content: const Text(errorMessage),
      actions: [okButton],
    );
  }
}
