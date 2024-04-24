import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

import "firebase_auth_user.dart";

final testingUserData = UserData(
  username: "username_8456",
  displayName: "display_name_8456",
  joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
  centauriPoints: 0,
);

final testingUserFirestoreId = UserIdFirestore(value: testingLoginUser.uid);

final testingUserFirestore = UserFirestore(
  uid: testingUserFirestoreId,
  data: testingUserData,
);

/// Helper class to generate mock user data to be used in tests
class FirestoreUserGenerator {
  static List<UserData> generateUserData(int count) {
    return List.generate(count, (i) {
      return UserData(
        displayName: "display_name_$i",
        username: "username_$i",
        joinTime: Timestamp.fromMillisecondsSinceEpoch(1000 * i),
        centauriPoints: i,
      );
    });
  }

  static List<UserFirestore> generateUserFirestore(int count) {
    return generateUserData(count).mapIndexed((i, data) {
      return UserFirestore(
        uid: UserIdFirestore(value: "user_id_$i"),
        data: data,
      );
    }).toList();
  }
}
