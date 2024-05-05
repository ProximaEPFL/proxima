import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/utils/ui/user_avatar/user_avatar.dart";
import "package:proxima/viewmodels/dynamic_user_avatar_view_model.dart";

/// This widget display a user's avatar.
class DynamicUserAvatar extends HookConsumerWidget {
  static const _loadingDisplayName = "";

  final UserIdFirestore? uid;
  final double radius;
  final VoidCallback? onTap;

  const DynamicUserAvatar({
    super.key,
    required this.uid,
    required this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayNameAsyncValue = ref.watch(userDisplayNameProvider(uid));

    return displayNameAsyncValue.when(
      data: (displayName) => UserAvatar(
        displayName: displayName,
        radius: radius,
        onTap: onTap,
      ),
      loading: () => UserAvatar(
        displayName: _loadingDisplayName,
        radius: radius,
        onTap: onTap,
      ),
      error: (error, _) => (throw Exception("User avatar error: $error")),
    );
  }
}
