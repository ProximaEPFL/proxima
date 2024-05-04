import "package:flutter/material.dart";

const centauriPointsSnackBarDuration = Duration(seconds: 4); // default value

/// the state ScaffoldMessenger.of(context)
/// Show a snackbar telling the user they won [value] Centauri points.
/// [scaffoldMessengerState] is the current state of the scaffolds,
/// on which to display the snackbar. It can typially be found
/// using [ScaffoldMessenger.of(context)].
void showCentauriPointsSnackBar(
  int value,
  ScaffoldMessengerState scaffoldMessengerState,
) {
  scaffoldMessengerState.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: centauriPointsSnackBarDuration,
      content: Text(
        "You won $value Centauri! 🎉",
      ),
    ),
  );
}
