import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/database/user/user_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/database/user/user_id_firestore.dart";
import "package:proxima/services/database/user_repository_service.dart";

import "../../mocks/data/firestore_user.dart";

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

    test("Set a valid user correctly with empty db", () async {
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
      final expectedUser = testingUserFirestore;

      await userCollection
          .doc(expectedUser.uid.value)
          .set(expectedUser.data.toDbData());

      final actualUser = await userRepo.getUser(expectedUser.uid);

      expect(actualUser, expectedUser);
    });

    test("Get user fails when firestore data format doesn't have all fields",
        () async {
      final expectedUser = testingUserFirestore;

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
      final expectedUser = testingUserFirestore;

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

    test("isUsernameTaken returns true when username is taken", () async {
      final expectedUser = testingUserFirestore;

      await userCollection
          .doc(expectedUser.uid.value)
          .set(expectedUser.data.toDbData());

      final isUsernameTaken =
          await userRepo.isUsernameTaken(expectedUser.data.username);

      expect(isUsernameTaken, true);
    });

    test("isUsernameTaken returns false when username is not taken", () async {
      final isUsernameTaken =
          await userRepo.isUsernameTaken("I love elephants :)");

      expect(isUsernameTaken, false);
    });

    test("Update centauri points", () async {
      final expectedUser = testingUserFirestore;

      await userCollection
          .doc(expectedUser.uid.value)
          .set(expectedUser.data.toDbData());

      const pointsToAdd = 100;

      await userRepo.addPoints(expectedUser.uid, pointsToAdd);

      //get the centauri points from the db
      final actualUserDoc =
          await userCollection.doc(expectedUser.uid.value).get();

      final actualCentauriPoints =
          actualUserDoc.data()![UserData.centauriPointsField];

      expect(
        actualCentauriPoints,
        expectedUser.data.centauriPoints + pointsToAdd,
      );
    });

    test("User ranking by top centauri points with enough users", () async {
      const numberOfUsers = 10;
      const limit = 5;

      // Generate users with different centauri points
      await FirestoreUserGenerator.addUsers(fakeFireStore, numberOfUsers);

      // Query top users using the service under test (actual)
      final topUsers = await userRepo.getTopUsers(limit);

      // Check that correct number of users are returned
      expect(topUsers.length, limit);

      // Compare actual points received with expected decreasing number of points
      final points = topUsers.map((u) => u.data.centauriPoints);
      final expectedPoints =
          Iterable.generate(limit).map((i) => numberOfUsers - i - 1);

      // Must be the same order
      expect(points, orderedEquals(expectedPoints));
    });

    test("User ranking by top centauri points with not enough users", () async {
      // Add a single user to the database
      await FirestoreUserGenerator.addUser(fakeFireStore);

      // Query more top users using the service under test than there are in DB
      final topUsers = await userRepo.getTopUsers(2);

      // Check that the maximum number of users are returned
      expect(topUsers.length, 1);

      // Must be the correct number of points
      expect(topUsers.first.data.centauriPoints, 0);
    });
  });
}
