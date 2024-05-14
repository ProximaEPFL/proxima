import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/viewmodels/dynamic_user_avatar_view_model.dart";
import "package:proxima/views/components/content/user_avatar/user_avatar.dart";

/// This widget display a user's avatar given its [uid].
/// If the [uid] is null, the current user's avatar is displayed.
/// It provides a [onTap] parameter to handle the user's tap,
/// which adds an InkWell response.
/// The [radius] parameter is the radius of the avatar.
class DynamicUserAvatar extends ConsumerWidget {
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
    final detailsAsyncValue = ref.watch(
      dynamicUserAvatarViewModelProvider(uid),
    );

    return detailsAsyncValue.when(
      data: (details) => UserAvatar(
        details: details.displayName,
        radius: radius,
        onTap: onTap,
      ),
      loading: () => UserAvatar(
        displayName: _loadingDisplayName,
        radius: radius,
        onTap: onTap,
      ),
      error: (error, _) => throw Exception("User avatar error: $error"),
    );
  }
}
