import "package:cloud_firestore/cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

enum DatabaseCollection {
  testUsers("test_users");

  final String name;

  const DatabaseCollection(this.name);
}

enum TestUsersFields {
  testName("test_name");

  final String name;

  const TestUsersFields(this.name);
}

/// Database service
class DatabaseService {
  final FirebaseFirestore _firestore;

  DatabaseService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<List<String>> testUsersNames() async {
    final users =
        await _firestore.collection(DatabaseCollection.testUsers.name).get();
    return users.docs
        .map((e) => e.data()[TestUsersFields.testName.name] as String)
        .toList();
  }
}

/// Static singleton [FirebaseFirestore] instance provider
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// Database provider
final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(
    firestore: ref.watch(firestoreProvider),
  );
});
