import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_auth_mocks/firebase_auth_mocks.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user_repository.dart";

void main() {
  group("User Data Firestore testing", () {
    test("hash overrides correctly", () {
      final data = UserDataFirestore(
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
        UserDataFirestore.usernameField: "username_8456",
        UserDataFirestore.displayNameField: "display_name_8456",
      };

      expect(
        () => UserDataFirestore.fromDbData(data),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group("User repository testing", () {
    final testLoggedUser = MockUser(
      isAnonymous: false,
      uid: "testing_user_id",
      email: "testing.user@gmail.com",
      displayName: "Testing User",
    );

    late FakeFirebaseFirestore fakeFireStore;
    late CollectionReference<Map<String, dynamic>> userCollection;
    late MockFirebaseAuth mockFirebaseAuth;
    late UserRepository userRepo;

    setUp(() async {
      fakeFireStore = FakeFirebaseFirestore();
      userCollection = fakeFireStore.collection(UserRepository.collectionName);
      mockFirebaseAuth =
          MockFirebaseAuth(signedIn: true, mockUser: testLoggedUser);
      userRepo = UserRepository(
        firebaseAuth: mockFirebaseAuth,
        firestore: fakeFireStore,
      );
    });

    test("Set a valid current user correctly with empty db", () async {
      final expectedUser = UserFirestore(
        uid: UserIdFirestore(value: testLoggedUser.uid),
        data: UserDataFirestore(
          username: "username_8456",
          displayName: "display_name_8456",
          joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
        ),
      );

      await userRepo.setCurrentUser(expectedUser.data);

      final actualUserCollection = await userCollection.get();
      final actualDocs = actualUserCollection.docs;

      expect(actualDocs.length, 1);

      final actualUser = actualDocs[0];
      expect(actualUser.id, expectedUser.uid.value);
      expect(
        actualUser.data()[UserDataFirestore.usernameField],
        expectedUser.data.username,
      );
      expect(
        actualUser.data()[UserDataFirestore.joinTimeField],
        expectedUser.data.joinTime,
      );
    });

    test("Get a user that does not exist fails", () async {
      expect(
        userRepo.getUser(const UserIdFirestore(value: "non_existent_user_id")),
        throwsA(isA<Exception>()),
      );
    });

    test("Get current user correctly", () async {
      final expectedUser = UserFirestore(
        uid: UserIdFirestore(value: testLoggedUser.uid),
        data: UserDataFirestore(
          username: "username_8456",
          displayName: "display_name_8456",
          joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
        ),
      );

      await userCollection
          .doc(expectedUser.uid.value)
          .set(expectedUser.data.toDbData());

      final actualUser = await userRepo.getCurrentUser();

      expect(actualUser, expectedUser);
    });

    test("Get current user fails when not logged in", () async {
      await mockFirebaseAuth.signOut();

      expect(
        userRepo.getCurrentUser(),
        throwsA(isA<Exception>()),
      );
    });

    test("Get user correctly", () async {
      final expectedUser = UserFirestore(
        uid: const UserIdFirestore(value: "user_id_1354"),
        data: UserDataFirestore(
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
        data: UserDataFirestore(
          username: "username_8456",
          displayName: "display_name_8456",
          joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
        ),
      );

      await userCollection.doc(expectedUser.uid.value).set({
        UserDataFirestore.usernameField: expectedUser.data.username,
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
        data: UserDataFirestore(
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
