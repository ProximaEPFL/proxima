import "package:proxima/services/database_service.dart";

import "../firestore/testing_firestore_provider.dart";

Future<void> generateFakeData() async {
  await fakeFireStore.collection(DatabaseCollection.testUsers.name).add({
    TestUsersFields.testName.name: "my_test_name",
  });
}
