final class CurrentUserData {
  final String id;
  final String displayName;
  final String username;
  final DateTime joinTime;

  CurrentUserData({
    required this.id,
    required this.displayName,
    required this.username,
    required this.joinTime,
  });

  ForeignUserData toForeign() {
    return ForeignUserData(
      id: id,
      displayName: displayName,
      username: username,
    );
  }
}

final class ForeignUserData {
  final String id;
  final String displayName;
  final String username;

  ForeignUserData({
    required this.id,
    required this.displayName,
    required this.username,
  });
}
