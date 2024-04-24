import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/firestore_service.dart";

final firebaseMocksOverrides = [
  firestoreProvider.overrideWith(mockFirestore),
];

final fakeFireStore = FakeFirebaseFirestore();

FirebaseFirestore mockFirestore(ProviderRef<FirebaseFirestore> ref) {
  return fakeFireStore;
}
