import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/data/user_data.dart";

void main() {
  group("User representation testing", () {
    test("Current user correctly created", () {
      final user = CurrentUserData(
        id: "user_id",
        displayName: "user_displayName",
        username: "user_username",
        joinTime: DateTime.utc(2021, 1, 1),
      );

      expect(user.id, "user_id");
      expect(user.displayName, "user_displayName");
      expect(user.username, "user_username");
      expect(user.joinTime, DateTime.utc(2021, 1, 1));
    });

    test("Foreign user correctly created", () {
      final user = ForeignUserData(
        id: "user_id",
        displayName: "user_displayName",
        username: "user_username",
      );

      expect(user.id, "user_id");
      expect(user.displayName, "user_displayName");
      expect(user.username, "user_username");
    });

    test("Conversion from current to foreign user", () {
      final user = CurrentUserData(
        id: "user_id",
        displayName: "user_displayName",
        username: "user_username",
        joinTime: DateTime.utc(2021, 1, 1),
      );

      final foreignUser = user.toForeign();

      expect(foreignUser.id, "user_id");
      expect(foreignUser.displayName, "user_displayName");
      expect(foreignUser.username, "user_username");
    });
  });
}
