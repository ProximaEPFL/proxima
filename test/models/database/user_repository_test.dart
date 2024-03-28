import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";

import "../../services/test_data/firestore_user_mock.dart";

void main() {
  group("User repository testing", () {
    late FakeFirebaseFirestore fakeFireStore;
    late CollectionReference<Map<String, dynamic>> userCollection;
    late UserRepositoryService userRepo;

    setUp(() async {
      fakeFireStore = FakeFirebaseFirestore();
      userCollection = fakeFireStore.collection(UserFirestore.collectionName);
      userRepo = UserRepositoryService(
        firestore: fakeFireStore,
      );
    });

    test("Set a valid current user correctly with empty db", () async {
      final expectedUser = testingUserFirestore;

      await userRepo.setUser(testingUserFirestoreId, expectedUser.data);

      final actualUserCollection = await userCollection.get();
      final actualDocs = actualUserCollection.docs;

      expect(actualDocs.length, 1);

      final actualUser = actualDocs[0];
      expect(actualUser.id, expectedUser.uid.value);
      expect(
        actualUser.data()[UserData.usernameField],
        expectedUser.data.username,
      );
      expect(
        actualUser.data()[UserData.joinTimeField],
        expectedUser.data.joinTime,
      );
    });

    test("Get a user that does not exist fails", () async {
      expect(
        userRepo.getUser(const UserIdFirestore(value: "non_existent_user_id")),
        throwsA(isA<Exception>()),
      );
    });

    test("Get user correctly", () async {
      final expectedUser = UserFirestore(
        uid: const UserIdFirestore(value: "user_id_1354"),
        data: UserData(
          username: "username_8456",
          displayName: "display_name_8456",
          joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
        ),
      );

      await userCollection
          .doc(expectedUser.uid.value)
          .set(expectedUser.data.toDbData());

      final actualUser = await userRepo.getUser(expectedUser.uid);

      expect(actualUser, expectedUser);
    });

    test("Get user fails when firestore data format doesn't have all fields",
        () async {
      final expectedUser = UserFirestore(
        uid: const UserIdFirestore(value: "user_id_1354"),
        data: UserData(
          username: "username_8456",
          displayName: "display_name_8456",
          joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
        ),
      );

      await userCollection.doc(expectedUser.uid.value).set({
        UserData.usernameField: expectedUser.data.username,
        // The joinTime field is missing on purpose
      });

      expect(
        userRepo.getUser(expectedUser.uid),
        throwsA(isA<FormatException>()),
      );
    });

    test("doesUserExists returns true when user exists", () async {
      final expectedUser = UserFirestore(
        uid: const UserIdFirestore(value: "user_id_1354"),
        data: UserData(
          username: "username_8456",
          displayName: "display_name_8456",
          joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
        ),
      );

      await userCollection
          .doc(expectedUser.uid.value)
          .set(expectedUser.data.toDbData());

      final actualUser = await userRepo.doesUserExist(expectedUser.uid);

      expect(actualUser, true);
    });

    test("doesUserExists returns false when user does not exist", () async {
      final actualUser = await userRepo
          .doesUserExist(const UserIdFirestore(value: "non_existent_user_id"));

      expect(actualUser, false);
    });
  });
}
