import "package:flutter/material.dart";

/// Used to show a snackbar telling the user they won [value] Centauri points.
class CentauriSnackBar extends SnackBar {
  static const pointsDuration = Duration(seconds: 4);

  final int value;

  CentauriSnackBar({
    super.key,
    required this.value,
  }) : super(
          behavior: SnackBarBehavior.floating,
          duration: pointsDuration,
          content: Text("You won $value Centauri! 🎉"),
        );
}
