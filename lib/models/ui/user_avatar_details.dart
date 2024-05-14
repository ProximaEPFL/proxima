import "dart:ui";

import "package:flutter/foundation.dart";

@immutable
class UserAvatarDetails {
  final String displayName;
  final Color? backgroundColor;

  const UserAvatarDetails({
    required this.displayName,
    required this.backgroundColor,
  });

  @override
  bool operator ==(Object other) {
    return other is UserAvatarDetails &&
        other.displayName == displayName &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode {
    return Object.hash(
      displayName,
      backgroundColor,
    );
  }
}
