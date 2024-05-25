import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/services/conversion/human_time_service.dart";
import "package:proxima/views/components/content/user_avatar/user_avatar.dart";
import "package:proxima/views/components/content/user_profile_pop_up.dart";

/// This widget is used to display the info bar in the post card.
/// It contains the user's profile picture and username
/// and the publication time of the post.
class PostCardHeader extends ConsumerWidget {
  static const avatarKey = Key("avatarKey");
  static const displayNameTextKey = Key("displayNameText");
  static const publicationDateTextKey = Key("publicationTimeTextKey");

  const PostCardHeader({
    super.key,
    required this.posterDisplayName,
    required this.posterUsername,
    required this.posterUserID,
    required this.posterCentauriPoints,
    required this.publicationDate,
  });

  final String posterDisplayName;
  final String posterUsername;
  final UserIdFirestore posterUserID;
  final int posterCentauriPoints;
  final DateTime publicationDate;

  void onTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => UserProfilePopUp(
        displayName: posterDisplayName,
        username: posterUsername,
        userID: posterUserID,
        centauriPoints: posterCentauriPoints,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final humanTimeService = ref.watch(humanTimeServiceProvider);

    final relativeTimeText = humanTimeService.textTimeSince(
      publicationDate,
    );
    final absoluteTimeText = humanTimeService.textTimeAbsolute(
      publicationDate,
    );

    final posterName = Flexible(
      child: InkWell(
        onTap: () => onTap(context),
        child: Text(
          posterDisplayName,
          key: displayNameTextKey,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      ),
    );

    const divider = Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        "•",
      ),
    );

    final publicationTime = Tooltip(
      message: absoluteTimeText,
      child: Text(
        key: publicationDateTextKey,
        relativeTimeText,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        UserAvatar(
          details: UserAvatarDetails(
            displayName: posterDisplayName,
            userID: posterUserID,
            userCentauriPoints: posterCentauriPoints,
          ),
          radius: 12,
          onTap: () => onTap(context),
          key: avatarKey,
        ),
        const SizedBox(width: 8),
        posterName,
        divider,
        publicationTime,
      ],
    );
  }
}
