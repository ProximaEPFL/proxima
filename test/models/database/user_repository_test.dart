import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_auth_mocks/firebase_auth_mocks.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user_repository.dart";

void main() {
  final testLoggedUser = MockUser(
    isAnonymous: false,
    uid: "testing_user_id",
    email: "testing.user@gmail.com",
    displayName: "Testing User",
  );

  var fakeFireStore = FakeFirebaseFirestore();
  final userCollection =
      fakeFireStore.collection(UserRepository.collectionName);

  final mockFirebaseAuth =
      MockFirebaseAuth(signedIn: true, mockUser: testLoggedUser);

  final userRepo =
      UserRepository(firebaseAuth: mockFirebaseAuth, firestore: fakeFireStore);

  setUp(() async {
    await fakeFireStore.clearPersistence();
  });

  group("User repository testing", () {
    test("Set a valid user correctly with empty db", () async {
      final expectedUser = UserFirestore(
        uid: "user_id_1354",
        username: "username_8456",
        joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
      );

      await userRepo.setUser(expectedUser);

      final actualUserCollection = await userCollection.get();
      final actualDocs = actualUserCollection.docs;

      expect(actualDocs.length, 1);

      final actualUser = actualDocs[0];
      expect(actualUser.id, expectedUser.uid);
      expect(
        actualUser.data()[UserFirestore.usernameField],
        expectedUser.username,
      );
      expect(
        actualUser.data()[UserFirestore.joinTimeField],
        expectedUser.joinTime,
      );
    });

    test("Set a user with empty uid fails", () async {
      final userToAdd = UserFirestore(
        uid: "",
        username: "username",
        joinTime: Timestamp.fromMillisecondsSinceEpoch(10000),
      );

      expect(
        userRepo.setUser(userToAdd),
        throwsA(isA<Exception>()),
      );
    });

    test("Get a user that does not exist fails", () async {
      expect(
        userRepo.getUser("non_existent_user_id"),
        throwsA(isA<Exception>()),
      );
    });

    test("Get current user correctly", () async {
      final expectedUser = UserFirestore(
        uid: testLoggedUser.uid,
        username: "username_8456",
        joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
      );

      await userCollection.doc(expectedUser.uid).set(expectedUser.toDb());

      final actualUser = await userRepo.getCurrentUser();

      expect(actualUser.uid, expectedUser.uid);
      expect(actualUser.username, expectedUser.username);
      expect(actualUser.joinTime, expectedUser.joinTime);
    });

    test("Get current user fails when not logged in", () async {
      final signedOutMockFirebaseAuth = MockFirebaseAuth(signedIn: false);
      final signedOutserRepo = UserRepository(
        firebaseAuth: signedOutMockFirebaseAuth,
        firestore: fakeFireStore,
      );

      expect(
        signedOutserRepo.getCurrentUser(),
        throwsA(isA<Exception>()),
      );
    });

    test("Get user correctly", () async {
      final expectedUser = UserFirestore(
        uid: "user_id_1354",
        username: "username_8456",
        joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
      );

      await userCollection.doc(expectedUser.uid).set(expectedUser.toDb());

      final actualUser = await userRepo.getUser(expectedUser.uid);

      expect(actualUser.uid, expectedUser.uid);
      expect(actualUser.username, expectedUser.username);
      expect(actualUser.joinTime, expectedUser.joinTime);
    });

    test("Get user fails when firestore data format doesn't have all fields",
        () async {
      final expectedUser = UserFirestore(
        uid: "user_id_1354",
        username: "username_8456",
        joinTime: Timestamp.fromMillisecondsSinceEpoch(10054217),
      );

      await userCollection.doc(expectedUser.uid).set({
        UserFirestore.usernameField: expectedUser.username,
        // The joinTime field is missing on purpose
      });

      expect(
        userRepo.getUser(expectedUser.uid),
        throwsA(isA<Exception>()),
      );
    });
  });
}
