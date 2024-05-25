import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/user_avatar_details.dart";

import "../../mocks/data/firestore_user.dart";

void main() {
  group("User avatar details testing", () {
    late UserAvatarDetails userAvatarDetails;

    setUp(() {
      userAvatarDetails = UserAvatarDetails.fromUserData(
        testingUserData,
        testingUserFirestoreId,
      );
    });

    test("Hash overrides correctly", () {
      final expectedHash = Object.hash(
        userAvatarDetails.displayName,
        userAvatarDetails.userID,
      );

      final actualHash = userAvatarDetails.hashCode;
      expect(actualHash, equals(expectedHash));
    });

    test("equality overrides correctly", () {
      // Copy made by the other constructor on purpose
      final userAvatarDetailsCopy = UserAvatarDetails(
        displayName: testingUserData.displayName,
        userID: testingUserFirestoreId,
      );

      expect(userAvatarDetails, equals(userAvatarDetailsCopy));
    });
  });
}
