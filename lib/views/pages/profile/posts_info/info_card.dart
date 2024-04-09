import "package:flutter/material.dart";

/// This widget defines the style of the cards in the profile page,
/// such as badges, posts and comments
class InfoCard extends StatelessWidget {
  static const cardKey = Key("card");

  const InfoCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: cardKey,
      width: 54,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}
