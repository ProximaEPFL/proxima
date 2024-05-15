import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/user_avatar_details.dart";
import "package:proxima/services/conversion/human_time_service.dart";
import "package:proxima/views/components/content/user_avatar/user_avatar.dart";

/// This widget is used to display the info bar in the post card.
/// It contains the user's profile picture and username
/// and the publication time of the post.
class PublicationHeader extends ConsumerWidget {
  static const displayNameTextKey = Key("displayNameText");
  static const publicationDateTextKey = Key("publicationTimeTextKey");

  const PublicationHeader({
    super.key,
    required this.posterUsername,
    required this.posterCentauriPoints,
    required this.publicationDate,
  });

  final String posterUsername;
  final int posterCentauriPoints;
  final DateTime publicationDate;

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
      child: Text(
        posterUsername,
        key: displayNameTextKey,
        softWrap: false,
        overflow: TextOverflow.fade,
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
            displayName: posterUsername,
            userCentauriPoints: posterCentauriPoints,
          ),
          radius: 12,
        ),
        const SizedBox(width: 8),
        posterName,
        divider,
        publicationTime,
      ],
    );
  }
}
