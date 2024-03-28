import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user/user_data.dart";

void main() {
  group("User Data testing", () {
    test("hash overrides correctly", () {
      final data = UserData(
        username: "username_8456",
        displayName: "display_name_8456",
        joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
      );

      final expectedHash = Object.hash(
        data.username,
        data.displayName,
        data.joinTime,
      );

      final actualHash = data.hashCode;

      expect(actualHash, expectedHash);
    });

    test("fromDbData throw error when missing fields", () {
      final data = <String, dynamic>{
        UserData.usernameField: "username_8456",
        UserData.displayNameField: "display_name_8456",
      };

      expect(
        () => UserData.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
