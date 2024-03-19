abstract class User {
  final String id;
  final String displayName;
  final String username;

  User({
    required this.id,
    required this.displayName,
    required this.username,
  });
}

final class CurrentUser extends User {
  final DateTime joinTime;

  CurrentUser({
    required super.id,
    required super.displayName,
    required super.username,
    required this.joinTime,
  });
}

final class ForeignUser extends User {
  ForeignUser({
    required super.id,
    required super.displayName,
    required super.username,
  });
}
