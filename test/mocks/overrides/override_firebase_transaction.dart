import "package:cloud_firestore/cloud_firestore.dart";

/// A mock class of a cloud firestore [Transaction].
/// This mock will always throw the [FirebaseException] error
/// when any of its method is called.
/// It is used to test the offline error handling of our services.
class MockErrorFirebaseTransaction implements Transaction {
  static const _plugin = "mock_error_firebase_transaction";

  @override
  Transaction delete(DocumentReference<Object?> documentReference) {
    throw FirebaseException(plugin: _plugin);
  }

  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(
    DocumentReference<T> documentReference,
  ) {
    throw FirebaseException(plugin: _plugin);
  }

  @override
  Transaction set<T>(
    DocumentReference<T> documentReference,
    T data, [
    SetOptions? options,
  ]) {
    throw FirebaseException(plugin: _plugin);
  }

  @override
  Transaction update(
    DocumentReference<Object?> documentReference,
    Map<String, dynamic> data,
  ) {
    throw FirebaseException(plugin: _plugin);
  }
}
