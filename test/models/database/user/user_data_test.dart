import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user/user_data.dart";

import "../../../mocks/data/mock_firestore_user.dart";

void main() {
  group("User Data testing", () {
    test("hash overrides correctly", () {
      final data = testingUserData;

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
