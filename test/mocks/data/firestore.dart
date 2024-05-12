import "package:cloud_firestore/cloud_firestore.dart";

class FirestoreGenerator {
  /// This is a workaround to get a non-existing document snapshot.
  static Future<DocumentSnapshot> getNonExistingDocSnapshot(
    FirebaseFirestore firestore,
  ) async {
    return await firestore.collection("mock").doc("no_existing").get();
  }
}
