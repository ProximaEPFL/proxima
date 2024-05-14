import "package:flutter/material.dart";
import "package:proxima/views/helpers/key_value_list_builder.dart";

class UserProfilePopUp extends StatelessWidget {
  final String displayName;
  final String username;
  final int centauriPoints;

  const UserProfilePopUp({
    super.key,
    required this.displayName,
    required this.username,
    required this.centauriPoints,
  });

  @override
  Widget build(BuildContext context) {
    final listBuilder =
        KeyValueListBuilder(style: DefaultTextStyle.of(context).style)
            .addPair("Username", username)
            .addPair("Score", "$centauriPoints Centauri");

    return AlertDialog(
      title: Text(displayName),
      content: listBuilder.generate(),
    );
  }
}
