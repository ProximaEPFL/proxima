import "package:flutter/material.dart";

/// Info card for the badges in profile
class ProfileBadge extends StatelessWidget {
  static const badgeKey = Key("profileBadge");

  const ProfileBadge({
    super.key,
    required this.shadow,
  });

  final BoxShadow shadow;

  @override
  Widget build(BuildContext context) {
    //TODO: replace with real badge data
    const badgeContent = Icon(Icons.star);

    return const Card(
      key: badgeKey,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: badgeContent,
      ),
    );
  }
}
