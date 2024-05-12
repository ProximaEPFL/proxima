import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";

class FirestoreGenerator {
  /// This is a workaround to get a non-existing document snapshot.
  static Future<DocumentSnapshot> getNonExistingDocSnapshot() async {
    final firestore = FakeFirebaseFirestore();
    return await firestore.collection("mock").doc("no_existing").get();
  }
}
