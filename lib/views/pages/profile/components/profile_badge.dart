import "package:flutter/material.dart";

/// Info card for the badges in profile
class ProfileBadge extends StatelessWidget {
  static const infoCardBadgeKey = Key("profileBadge");

  const ProfileBadge({
    super.key,
    required this.shadow,
  });

  final BoxShadow shadow;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      boxShadow: [shadow],
    );

    //TODO: replace with real badge data
    const badgeContent = Icon(
      Icons.star,
      size: 32,
    );

    return Container(
      key: infoCardBadgeKey,
      width: 54,
      height: 80,
      decoration: decoration,
      child: badgeContent,
    );
  }
}