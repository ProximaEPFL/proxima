import "package:flutter/material.dart";

//info card for the badges
class InfoCardBadge extends StatelessWidget {
  static const cardKey = Key("card");

  const InfoCardBadge({
    super.key,
    required this.shadow,
  });

  final BoxShadow shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: cardKey,
      width: 54,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow:[shadow],
      ),
      child: const Icon(
        Icons.star,
        size: 32,
      )
    );
  }
}
