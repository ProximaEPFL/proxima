import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:proxima/utils/ui/user_avatar.dart";
import "package:timeago/timeago.dart";

/// Converts a timestamp to a time ago string.
String timestampToTimeAgo(Timestamp timestamp) {
  return format(timestamp.toDate(), locale: "en_short");
}

/// Converts a timestamp to a user readable date string.
String timestampToDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  DateFormat formatter = DateFormat("EEEE, MMMM d, yyyy HH:mm 'UTC'z");
  return formatter.format(dateTime.toUtc());
}

/// This widget is used to display the info bar in the post card.
/// It contains the user's profile picture and username
/// and the publication time of the post.
class PostHeaderWidget extends StatelessWidget {
  static const displayNameTextKey = Key("displayNameText");
  static const timestampTextKey = Key("timestampText");

  const PostHeaderWidget({
    super.key,
    required this.posterUsername,
    required this.postTimestamp,
  });

  final String posterUsername;
  final Timestamp postTimestamp;

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
      message: timestampToDate(postTimestamp),
      child: Text(
        key: timestampTextKey,
        timestampToTimeAgo(postTimestamp),
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
