import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";

@immutable
class UserData {
  final String username;
  static const String usernameField = "username";

  final String displayName;
  static const String displayNameField = "displayName";

  final Timestamp joinTime;
  static const joinTimeField = "joinTime";

  final int centauriPoints;
  static const centauriPointsField = "centauriPoints";

  const UserData({
    required this.username,
    required this.displayName,
    required this.joinTime,
    required this.centauriPoints,
  });

  /// This method will create an instance of [UserData] from the
  /// data map [data] that comes from firestore
  factory UserData.fromDbData(Map<String, dynamic> data) {
    try {
      return UserData(
        username: data[usernameField],
        displayName: data[displayNameField],
        joinTime: data[joinTimeField],
        centauriPoints: data[centauriPointsField] ?? 0,
      );
    } catch (e) {
      if (e is TypeError) {
        throw FormatException(
          "Cannot parse user data document: ${e.toString()}",
        );
      } else {
        rethrow;
      }
    }
  }

  UserData withPointsAddition(int points) {
    return UserData(
      username: username,
      displayName: displayName,
      joinTime: joinTime,
      centauriPoints: centauriPoints + points,
    );
  }

  /// This method will create a map from the current instance of [UserData]
  /// to be stored in firestore
  Map<String, dynamic> toDbData() {
    return {
      usernameField: username,
      displayNameField: displayName,
      joinTimeField: joinTime,
      centauriPointsField: centauriPoints,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is UserData &&
        other.username == username &&
        other.displayName == displayName &&
        other.joinTime == joinTime;
  }

  @override
  int get hashCode => Object.hash(username, displayName, joinTime);
}
