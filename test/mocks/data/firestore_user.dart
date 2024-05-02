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

  static List<UserFirestore> generateUserFirestoreWithId(
    List<UserIdFirestore> ids,
  ) {
    return generateUserData(ids.length).mapIndexed((i, data) {
      return UserFirestore(
        uid: ids[i],
        data: data,
      );
    }).toList();
  }

  static List<UserFirestore> generateUserFirestore(int count) {
    return generateUserFirestoreWithId(
      List.generate(count, (i) => UserIdFirestore(value: "user_id_$i")),
    );
  }
}

/// Helper function to set a user in the firestore db
Future<void> setUserFirestore(
  FirebaseFirestore firestore,
  UserFirestore user,
) async {
  await firestore
      .collection(UserFirestore.collectionName)
      .doc(user.uid.value)
      .set({...user.data.toDbData()});
}

Future<void> setUsersFirestore(
  FirebaseFirestore firestore,
  List<UserFirestore> users,
) async {
  for (final user in users) {
    await setUserFirestore(firestore, user);
  }
}
