import "package:flutter/material.dart";

/// This widget defines the style of the cards in the profile page,
/// such as badges, posts and comments
class InfoCard extends StatelessWidget {
  static const cardKey = Key("card");

  const InfoCard({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: cardKey,
      width: 54,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}
