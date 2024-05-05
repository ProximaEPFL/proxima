import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/utils/ui/user_avatar.dart";
import "package:proxima/viewmodels/profile_view_model.dart";

/// This widget display the current user's avatar.
class PersonalUserAvatar extends HookConsumerWidget {
  final _defaultDisplayName = "";

  final double radius;
  final VoidCallback? onTap;

  const PersonalUserAvatar({
    super.key,
    required this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUserData = ref.watch(profileProvider);
    var displayName = _defaultDisplayName;
    asyncUserData.when(
      data: (userData) {
        displayName = userData.firestoreUser.data.displayName;
      },
      loading: () {},
      error: (error, stackTrace) {},
    );

    return UserAvatar(
      displayName: displayName,
      radius: radius,
      onTap: onTap,
    );
  }
}
