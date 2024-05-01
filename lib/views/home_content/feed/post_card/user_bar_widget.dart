import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:proxima/utils/ui/user_avatar.dart";
import "package:timeago/timeago.dart";

/// This widget is used to display the user bar in the post card.
/// It contains the user's profile picture and username.
class UserBarWidget extends StatelessWidget {
  static const displayNameTextKey = Key("displayNameText");
  static const timestampTextKey = Key("timestampText");

  const UserBarWidget({
    super.key,
    required this.posterUsername,
    required this.postTimestamp,
  });

  final String posterUsername;
  final Timestamp postTimestamp;

  /// Converts a timestamp to a time ago string.
  String _timestampToTimeAgo(Timestamp timestamp) {
    return "${format(timestamp.toDate(), locale: "en_short")} ago";
  }

  /// Converts a timestamp to a user readable date string.
  String _timestampToDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateFormat formatter = DateFormat("EEEE, MMMM d, yyyy HH:mm 'UTC'z");
    return formatter.format(dateTime.toUtc());
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
      message: _timestampToDate(postTimestamp),
      child: Text(
        key: timestampTextKey,
        _timestampToTimeAgo(postTimestamp),
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
