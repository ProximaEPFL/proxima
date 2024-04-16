import "package:firebase_auth_mocks/firebase_auth_mocks.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/login_service.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/navigation/routes.dart";
import "package:proxima/views/pages/home/home_page.dart";
import "package:proxima/views/pages/home/top_bar/app_top_bar.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_badge.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_comment.dart";
import "package:proxima/views/pages/profile/posts_info/info_card_post.dart";
import "package:proxima/views/pages/profile/posts_info/info_row.dart";
import "package:proxima/views/pages/profile/posts_info/popup/comment_popup.dart";
import "package:proxima/views/pages/profile/posts_info/popup/post_popup.dart";
import "package:proxima/views/pages/profile/profile_page.dart";
import "package:proxima/views/pages/profile/user_info/user_account.dart";
import "../services/firebase/setup_firebase_mocks.dart";
import "../viewmodels/mock_home_view_model.dart";

void main() {
  late ProviderScope mockedProfilePage;
  late MockFirebaseAuth auth;

  setUp(() async {
    setupFirebaseAuthMocks();
    auth = MockFirebaseAuth(signedIn: true);
    mockedProfilePage = ProviderScope(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
        postOverviewProvider.overrideWith(
          () => MockHomeViewModel(),
        ),
      ],
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        title: "Proxima",
        home: ProfilePage(),
      ),
    );
  });

  group("Widgets display", () {
    testWidgets("Display badges, posts and comments", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle();

      //Check that the tab is displayed
      final tab = find.byKey(ProfilePage.tabKey);
      expect(tab, findsOneWidget);

      // Check that the post tab is displayed
      final postTab = find.byKey(ProfilePage.postTabKey);
      expect(postTab, findsOneWidget);

      // Check that the comment tab is displayed
      final commentTab = find.byKey(ProfilePage.commentTabKey);
      expect(commentTab, findsOneWidget);

      // Check that badges are displayed
      final badgeCard = find.byKey(InfoCardBadge.infoCardBadgeKey);
      expect(badgeCard, findsWidgets);

      //Check that the post card is displayed
      final postCard = find.byKey(InfoCardPost.infoCardPostKey);
      expect(postCard, findsWidgets);

      // Check that the info column is displayed
      final infoColumn = find.byKey(ProfilePage.postColumnKey);
      expect(infoColumn, findsOneWidget);

      // Check that the info row is displayed
      final infoRowWidget = find.byKey(InfoRow.infoRowKey);
      expect(infoRowWidget, findsOneWidget);

      //Check that centauri points are displayed
      final centauriPoints = find.byKey(UserAccount.centauriPointsKey);
      expect(centauriPoints, findsOneWidget);

      //Check that the user account is displayed
      final userAccount = find.byKey(UserAccount.userInfoKey);
      expect(userAccount, findsOneWidget);

      //Check that post column is displayed
      final postColumn = find.byKey(ProfilePage.postColumnKey);
      expect(postColumn, findsOneWidget);

      // Tap on the comment tab
      await tester.tap(commentTab);
      await tester.pumpAndSettle();

      // Check that the comment column is displayed
      final commentColumn = find.byKey(ProfilePage.commentColumnKey);
      expect(commentColumn, findsOneWidget);
    });
  });

  group("Popups working as expected", () {
    testWidgets("Post popup working as expected", (tester) async {
      await tester.pumpWidget(mockedProfilePage);
      await tester.pumpAndSettle();

      //Check tab on the first post
      final infoCardPost = find.byKey(InfoCardPost.infoCardPostKey);
      expect(infoCardPost, findsWidgets);

      // Tap on the first post
      await tester.tap(infoCardPost.first);
      await tester.pumpAndSettle();

      // Check that the post popup is displayed
      final postPopup = find.byType(PostPopUp);
      expect(postPopup, findsOneWidget);

      //Check that the title of the pop up is displayed
      final postPopupTitle = find.byKey(PostPopUp.postPopUpTitleKey);
      expect(postPopupTitle, findsOneWidget);

      //Check that the description of the pop up is displayed
      final postPopupDescription =
          find.byKey(PostPopUp.postPopUpDescriptionKey);
      expect(postPopupDescription, findsOneWidget);

      //Check that the delete button is displayed
      final postPopupDeleteButton =
          find.byKey(PostPopUp.postPopUpDeleteButtonKey);
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
      final infoCardComment = find.byKey(InfoCardComment.infoCardCommentKey);
      expect(infoCardComment, findsWidgets);

      // Tap on the first comment
      await tester.tap(infoCardComment.first);
      await tester.pumpAndSettle();

      // Check that the comment popup is displayed
      final commentPopup = find.byType(CommentPopUp);
      expect(commentPopup, findsOneWidget);

      //Check that the description of the pop up is displayed
      final commentPopupDescription =
          find.byKey(CommentPopUp.commentPopUpDescriptionKey);
      expect(commentPopupDescription, findsOneWidget);

      //Check that the delete button is displayed
      final commentPopupDeleteButton =
          find.byKey(CommentPopUp.commentPopUpDeleteButtonKey);
      expect(commentPopupDeleteButton, findsOneWidget);

      //Check clicking on the delete button come back to the profile page
      await tester.tap(commentPopupDeleteButton);
      await tester.pumpAndSettle();

      //Check that the profile page is displayed
      final profilePage = find.byType(ProfilePage);
      expect(profilePage, findsOneWidget);
    });
  });

  testWidgets("Navigate from overview to profile page", (tester) async {
    final homePageWidget = ProviderScope(
      overrides: [
        postOverviewProvider.overrideWith(
          () => MockHomeViewModel(),
        ),
      ],
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        title: "Proxima",
        home: HomePage(),
      ),
    );

    await tester.pumpWidget(homePageWidget);
    await tester.pumpAndSettle();

    // Check that the top bar is displayed
    final topBar = find.byKey(AppTopBar.homeTopBarKey);
    expect(topBar, findsOneWidget);

    //Check profile picture is displayed
    final profilePicture = find.byKey(AppTopBar.profilePictureKey);
    expect(profilePicture, findsOneWidget);

    // Tap on the profile picture
    await tester.tap(profilePicture);
    await tester.pumpAndSettle();

    // Check that the profile page is displayed
    final profilePage = find.byType(ProfilePage);
    expect(profilePage, findsOneWidget);
  });
}
