import "package:flutter/material.dart";

/// Info card for the badges in profile
class ProfileBadge extends StatelessWidget {
  static const badgeKey = Key("profileBadge");

  static const _badgeWidth = 54.0;
  static const _badgeHeight = 80.0;
  static const _badgeIconSize = 32.0;

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
    const badgeContent = Icon(Icons.star, size: _badgeIconSize);

    return Container(
      key: badgeKey,
      width: _badgeWidth,
      height: _badgeHeight,
      decoration: decoration,
      child: badgeContent,
    );
  }
}
