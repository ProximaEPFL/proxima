import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:proxima/utils/ui/user_avatar/user_avatar.dart";
import "package:timeago/timeago.dart" as timeago;

/// This widget is used to display the info bar in the post card.
/// It contains the user's profile picture and username
/// and the publication time of the post.
class PostHeaderWidget extends StatelessWidget {
  static const displayNameTextKey = Key("displayNameText");
  static const publicationDateTextKey = Key("publicationTimeTextKey");

  const PostHeaderWidget({
    super.key,
    required this.posterUsername,
    required this.publicationDate,
  });

  final String posterUsername;
  final DateTime publicationDate;

  /// Converts a timestamp to a time ago string.
  String _dateTimeToTimeAgo(DateTime dateTime) {
    return "${timeago.format(dateTime, locale: "en_short")} ago";
  }

  /// Converts a timestamp to a user readable date string.
  String _dateFormat(DateTime dateTime) {
    DateFormat formatter = DateFormat("EEEE, MMMM d, yyyy HH:mm");
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
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
      message: _dateFormat(publicationDate),
      child: Text(
        key: publicationDateTextKey,
        _dateTimeToTimeAgo(publicationDate),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        UserAvatar(displayName: posterUsername, radius: 12),
        const SizedBox(width: 8),
        posterName,
        divider,
        publicationTime,
      ],
    );
  }
}
