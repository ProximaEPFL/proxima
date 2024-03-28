import "package:cloud_firestore/cloud_firestore.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";

import "firebase_auth_user_mock.dart";

final testingUserData = UserDataFirestore(
  username: "username_8456",
  displayName: "display_name_8456",
  joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
);

final testingUserFirestoreId = UserIdFirestore(value: testingLoginUser.uid);

final testingUserFirestore = UserFirestore(
  uid: testingUserFirestoreId,
  data: testingUserData,
);
