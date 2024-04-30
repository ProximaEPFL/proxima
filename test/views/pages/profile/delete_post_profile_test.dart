import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_location_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/views/pages/profile/info_cards/profile_info_card.dart";
import "package:proxima/views/pages/profile/profile_data/profile_user_posts.dart";

import "../../../mocks/data/firestore_post.dart";
import "../../../mocks/data/firestore_user.dart";
import "../../../mocks/data/geopoint.dart";
import "../../../mocks/providers/provider_profile_page.dart";
import "../../../mocks/services/setup_firebase_mocks.dart";

void main() {
  const delayNeededForAsyncFunctionExecution = Duration(seconds: 1);

  late FakeFirebaseFirestore fakeFireStore;
  late CollectionReference<Map<String, dynamic>> userCollection;
  late ProviderScope mockedProfilePage;

  final expectedUser = testingUserFirestore;

  setUp(() async {
    setupFirebaseAuthMocks();
    fakeFireStore = FakeFirebaseFirestore();
    userCollection = fakeFireStore.collection(UserFirestore.collectionName);

    await userCollection
        .doc(expectedUser.uid.value)
        .set(expectedUser.data.toDbData());

    final postsGenerator = FirestorePostGenerator();
    setPostFirestore(
      postsGenerator.createUserPost(testingUserFirestoreId, userPosition1),
      fakeFireStore,
    );

    mockedProfilePage = profilePageProvider(
      fakeFireStore,
    );
  });

  group("Profile Post Delete", () {
    testWidgets("Delete post using card", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      // Check that the post card is displayed
      final postCard = find.byKey(ProfileInfoCard.infoCardKey);
      expect(postCard, findsOneWidget);

      // Find the delete button on card
      final deleteButton = find.byKey(ProfileInfoCard.deleteButtonCardKey);
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      // Find the empty user posts text
      final noPostHelper = find.text(ProfileUserPosts.noPostsInfoText);
      expect(noPostHelper, findsOneWidget);

      // Check no posts left in fake database
      final userPosts =
          await fakeFireStore.collection(PostFirestore.collectionName).get();
      final posts =
          userPosts.docs.map((data) => PostFirestore.fromDb(data)).toList();

      expect(posts.isEmpty, true);
    });
  });
}
