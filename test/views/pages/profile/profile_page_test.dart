import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/services/database/comment/comment_repository_service.dart";
import "package:proxima/views/components/content/info_pop_up.dart";
import "package:proxima/views/components/content/user_avatar/user_avatar.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/home/home_top_bar/home_top_bar.dart";
import "package:proxima/views/pages/profile/components/info_cards/profile_info_card.dart";
import "package:proxima/views/pages/profile/components/info_cards/profile_info_pop_up.dart";
import "package:proxima/views/pages/profile/components/profile_data/profile_user_posts.dart";
import "package:proxima/views/pages/profile/components/user_account.dart";
import "package:proxima/views/pages/profile/profile_page.dart";

import "../../../mocks/data/comment_data.dart";
import "../../../mocks/data/firestore_post.dart";
import "../../../mocks/data/firestore_user.dart";
import "../../../mocks/data/geopoint.dart";
import "../../../mocks/providers/provider_homepage.dart";
import "../../../mocks/providers/provider_profile_page.dart";
import "../../../mocks/services/setup_firebase_mocks.dart";
import "../../../utils/delay_async_func.dart";

void main() {
  late FakeFirebaseFirestore fakeFireStore;
  late CollectionReference<Map<String, dynamic>> userCollection;
  late ProviderScope mockedProfilePage;
  late PostFirestore fakePost;
  late CommentRepositoryService commentRepo;

  final expectedUser = testingUserFirestore;

  setUp(() async {
    setupFirebaseAuthMocks();
    final postsGenerator = FirestorePostGenerator();
    fakeFireStore = FakeFirebaseFirestore();
    userCollection = fakeFireStore.collection(UserFirestore.collectionName);
    fakePost =
        postsGenerator.createUserPost(testingUserFirestoreId, userPosition1);

    await userCollection
        .doc(expectedUser.uid.value)
        .set(expectedUser.data.toDbData());

    setPostFirestore(
      fakePost,
      fakeFireStore,
    );

    //get the comment repository service to add comments
    commentRepo = CommentRepositoryService(
      firestore: fakeFireStore,
    );

    final commentDataGenerator = CommentDataGenerator();

    final mockComment =
        commentDataGenerator.createMockCommentData(ownerId: expectedUser.uid);

    await commentRepo.addComment(
      fakePost.id,
      mockComment,
    );

    mockedProfilePage = profileProviderScope(fakeFireStore, profilePageApp);
  });

  group("Widgets display", () {
    testWidgets("Display badges, posts comments and centauri", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      //Check that the user account is displayed
      final userAccount = find.byKey(UserAccount.userInfoKey);
      expect(userAccount, findsOneWidget);

      //Check user initial is displayed in the user account bar
      final userInitial = find.descendant(
        of: userAccount,
        matching: find.byKey(UserAvatar.initialDisplayNameKey),
      );
      expect(userInitial, findsOneWidget);

      //Check that the first initial of the test user is displayed
      final Text textWidget = tester.widget(userInitial) as Text;
      expect(textWidget.data, equals(testingUserFirestore.data.displayName[0]));

      //Check that centauri points are displayed
      final centauriPoints = find.byKey(UserAccount.centauriPointsKey);
      expect(centauriPoints, findsOneWidget);

      //Check that the tab is displayed
      final tab = find.byKey(ProfilePage.tabKey);
      expect(tab, findsOneWidget);

      // Check that the post info column is displayed
      final infoColumn = find.byKey(ProfileUserPosts.postColumnKey);
      expect(infoColumn, findsOneWidget);

      //Check that the post card is displayed
      final postCard = find.byKey(ProfileInfoCard.infoCardKey);
      expect(postCard, findsWidgets);

      // Check that post data is displayed
      expect(find.textContaining(fakePost.data.title), findsOneWidget);
      expect(find.textContaining(fakePost.data.description), findsOneWidget);
    });
  });

  group("Functionality", () {
    testWidgets("Post popup working as expected", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      //Check tab on the first post
      final infoCardPost = find.byKey(ProfileInfoCard.infoCardKey);
      expect(infoCardPost, findsWidgets);

      // Tap on the first post
      await tester.tap(infoCardPost.first);
      await tester.pumpAndSettle();

      // Check that the post popup is displayed
      final postPopup = find.byType(ProfileInfoPopUp);
      expect(postPopup, findsOneWidget);

      //Check that the title of the pop up is displayed
      final postPopupTitle = find.byKey(InfoPopUp.popUpTitleKey);
      expect(postPopupTitle, findsOneWidget);

      //Check that the description of the pop up is displayed
      final postPopupDescription = find.byKey(InfoPopUp.popUpDescriptionKey);
      expect(postPopupDescription, findsOneWidget);

      // Check that post content is displayed on popup
      final titleContent = find.descendant(
        of: postPopup,
        matching: find.textContaining(fakePost.data.title),
      );
      final descriptionContent = find.descendant(
        of: postPopup,
        matching: find.textContaining(fakePost.data.description),
      );
      expect(titleContent, findsOneWidget);
      expect(descriptionContent, findsOneWidget);

      //Check that the delete button is displayed
      final postPopupDeleteButton = find.byKey(ProfileInfoPopUp.popUpButtonKey);
      expect(postPopupDeleteButton, findsOneWidget);

      //Check clicking on the delete button come back to the profile page
      await tester.tap(postPopupDeleteButton);
      await tester.pumpAndSettle();

      //Check that the profile page is displayed
      final profilePage = find.byType(ProfilePage);
      expect(profilePage, findsOneWidget);
    });

    testWidgets("Comment popup working as expected", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle();

      // Tap on the comment tab
      final commentTab = find.byKey(ProfilePage.commentTabKey);
      await tester.tap(commentTab);
      await tester.pumpAndSettle();

      //Check tab on the first comment
      final infoCardComment = find.byKey(ProfileInfoCard.infoCardKey);
      expect(infoCardComment, findsWidgets);

      // Tap on the first comment
      await tester.tap(infoCardComment.first);
      await tester.pumpAndSettle();

      // Check that the comment popup is displayed
      final commentPopup = find.byType(ProfileInfoPopUp);
      expect(commentPopup, findsOneWidget);

      //Check that the description of the pop up is displayed
      final commentPopupDescription = find.byKey(InfoPopUp.popUpDescriptionKey);
      expect(commentPopupDescription, findsOneWidget);

      //Check that the delete button is displayed
      final commentPopupDeleteButton =
          find.byKey(ProfileInfoPopUp.popUpButtonKey);
      expect(commentPopupDeleteButton, findsOneWidget);

      //Check clicking on the delete button come back to the profile page
      await tester.tap(commentPopupDeleteButton);
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      //Check that the profile page is displayed
      final profilePage = find.byType(ProfilePage);
      expect(profilePage, findsOneWidget);

      //check that the comment is deleted
      final noInfoCardComment = find.byKey(ProfileInfoCard.infoCardKey);
      expect(noInfoCardComment, findsNothing);

      final userComments = await commentRepo.getUserComments(expectedUser.uid);
      expect(userComments, isEmpty);
    });

    testWidgets("Tab working as expected", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle();

      // Check that the post tab is displayed
      final postTab = find.byKey(ProfilePage.postTabKey);
      expect(postTab, findsOneWidget);

      // Check that the comment tab is displayed
      final commentTab = find.byKey(ProfilePage.commentTabKey);
      expect(commentTab, findsOneWidget);

      //Check that post column is displayed
      final postColumn = find.byKey(ProfileUserPosts.postColumnKey);
      expect(postColumn, findsOneWidget);

      // Tap on the comment tab
      await tester.tap(commentTab);
      await tester.pumpAndSettle();

      // Check that the comment column is displayed
      final commentColumn = find.byKey(ProfilePage.commentColumnKey);
      expect(commentColumn, findsOneWidget);
    });

    testWidgets("Centauri points displayed correctly", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle();

      //Check that centauri points are displayed
      final centauriPoints = find.byKey(UserAccount.centauriPointsKey);
      expect(centauriPoints, findsOneWidget);

      // checking the text
      final centauriText = find.text("username_8456 · 0 Centauri");
      expect(centauriText, findsOneWidget);
    });

    testWidgets("Posts refreshing works correctly", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle();

      // Check that the profile page is displayed
      final profilePage = find.byType(ProfilePage);
      expect(profilePage, findsOneWidget);

      // Check that the post info column is displayed
      final postColumn = find.byKey(ProfileUserPosts.postColumnKey);
      expect(postColumn, findsOneWidget);

      // Refresh the user posts
      await tester.fling(postColumn, const Offset(100, 400.0), 1000.0);
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      // Check that refreshing was handled correctly
      expect(find.byKey(ProfileUserPosts.postColumnKey), findsOneWidget);

      // Check that the post card is displayed
      final postCard = find.byKey(ProfileInfoCard.infoCardKey);
      expect(postCard, findsOneWidget);
    });
  });

  group("Navigation", () {
    testWidgets("Navigate from overview to profile page", (tester) async {
      final homePageWidget = emptyHomePageProvider;
      await tester.pumpWidget(homePageWidget);
      await tester.pumpAndSettle();

      // Check that the top bar is displayed
      final topBar = find.byKey(HomeTopBar.homeTopBarKey);
      expect(topBar, findsOneWidget);

      //Check profile picture is displayed
      final profilePicture = find.byKey(HomeTopBar.profilePictureKey);
      expect(profilePicture, findsOneWidget);

      // Tap on the profile picture
      await tester.tap(profilePicture);
      await tester.pumpAndSettle();

      // Check that the profile page is displayed
      final profilePage = find.byType(ProfilePage);
      expect(profilePage, findsOneWidget);
    });

    testWidgets("Check that user centauri points count updates correctly.",
        (tester) async {
      await tester.pumpWidget(profileProviderScope(fakeFireStore, homePageApp));
      await tester.pumpAndSettle();

      final userPoints = expectedUser.data.centauriPoints.toString();
      const increment = 10;

      // Navigate to profile
      await tester.tap(find.byKey(HomeTopBar.profilePictureKey));
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      // Check correct centauri points
      expect(find.textContaining(userPoints), findsOneWidget);

      // Navigate back to home page
      await tester.tap(find.byType(LeadingBackButton));
      await tester.pumpAndSettle();

      // Change the user points
      await userCollection
          .doc(expectedUser.uid.value)
          .set(expectedUser.data.withPointsAddition(increment).toDbData());

      // Navigate back to profile page
      await tester.tap(find.byKey(HomeTopBar.profilePictureKey));
      await tester.pumpAndSettle(delayNeededForAsyncFunctionExecution);

      // Check update centauri points
      final updatedUserPoints =
          (expectedUser.data.centauriPoints + increment).toString();
      expect(find.textContaining(updatedUserPoints), findsOneWidget);
    });
  });
}
