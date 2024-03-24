import "package:flutter/material.dart";

class UserBarWidget extends StatelessWidget {
  const UserBarWidget({
    super.key,
    required this.posterUsername,
  });

  final String posterUsername;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12.0,
          child: Text(posterUsername.substring(0, 1)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(posterUsername),
        ),
      ],
    );
  }
}
