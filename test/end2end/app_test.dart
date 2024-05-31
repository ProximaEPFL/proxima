import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/database/challenge_repository_service.dart";
import "package:proxima/services/database/firestore_service.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/views/navigation/bottom_navigation_bar/navigation_bar_routes.dart";
import "package:proxima/views/pages/home/content/challenge/challenge_list.dart";
import "package:proxima/views/pages/profile/components/profile_app_bar.dart";
import "package:proxima/views/proxima_app.dart";

import "../mocks/data/firestore_post.dart";
import "../mocks/data/firestore_user.dart";
import "../mocks/data/geopoint.dart";
import "../mocks/overrides/override_auth_providers.dart";
import "../mocks/services/mock_geo_location_service.dart";
import "../mocks/services/setup_firebase_mocks.dart";
import "app_actions.dart";

void main() {
  const testPostTitle = "I like turtles";
  const testPostDescription = "Look at them go!";

  late FakeFirebaseFirestore fakeFireStore;

  MockGeolocationService geoLocationService = MockGeolocationService();
  const GeoPoint startLocation = userPosition1;

  late FirestorePostGenerator firestorePostGenerator;

  setUp(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    fakeFireStore = FakeFirebaseFirestore();

    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(startLocation),
    );
    when(geoLocationService.getPositionStream()).thenAnswer(
      (_) => Stream.value(startLocation),
    );
    when(geoLocationService.checkLocationServices()).thenAnswer(
      (_) => Future.value(null),
    );

    firestorePostGenerator = FirestorePostGenerator();
  });

  /// Pump the full Proxima app into the tester.
  Future<void> loadProxima(WidgetTester tester) async {
    // Set up the app with mocked providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...firebaseAuthMocksOverrides,
          geolocationServiceProvider.overrideWithValue(geoLocationService),
          firestoreProvider.overrideWithValue(fakeFireStore),
        ],
        child: const ProximaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Change the current location to [point] in the geoLocationService.
  void goToPoint(GeoPoint point) {
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(point),
    );
    when(geoLocationService.getPositionStream()).thenAnswer(
      (_) => Stream.value(point),
    );
  }

  testWidgets("End-to-end test of the app navigation flow",
      (WidgetTester tester) async {
    await loadProxima(tester);

    await AppActions.loginToCreateAccount(tester);
    await AppActions.createAccountToHome(tester);
    await AppActions.homeToProfilePage(tester);
    await AppActions.bottomNavigation(tester);
    await AppActions.createPost(tester, testPostTitle, testPostDescription);
    await AppActions.deletePost(tester, testPostTitle, testPostDescription);
  });

  testWidgets("Challenge creation and completion", (WidgetTester tester) async {
    // create a post that will be the challenge
    final otherUser = await FirestoreUserGenerator.addUser(fakeFireStore);
    final postLocation = GeoPointGenerator.createOnEdgeInsidePosition(
      startLocation,
      ChallengeRepositoryService.maxChallengeRadius,
    );
    final post =
        firestorePostGenerator.createUserPost(otherUser.uid, postLocation);
    await setPostFirestore(post, fakeFireStore);

    await loadProxima(tester);
    await AppActions.loginToCreateAccount(tester);
    await AppActions.createAccountToHome(tester);

    // get the challenge
    await AppActions.bottomBarNavigate(NavigationBarRoutes.challenge, tester);
    expect(find.text(post.data.title), findsOneWidget);

    // complete the challenge with intermediate positions
    List<GeoPoint> intermediatePositions =
        GeoPointGenerator.linearInterpolation(startLocation, postLocation, 10);
    for (final point in intermediatePositions) {
      goToPoint(point);
      await AppActions.flingRefresh(tester, find.byType(ChallengeList));

      final challengeDescription = find.textContaining(
        "meters",
        findRichText: true,
      );
      expect(challengeDescription, findsOne);

      final challengeDescriptionWidget =
          challengeDescription.evaluate().first.widget as RichText;
      final challengeDescriptionText =
          challengeDescriptionWidget.text.toPlainText();

      // use regex to extract <number> meters
      final actualDist = int.parse(
        RegExp(r"(\d+) meters").firstMatch(challengeDescriptionText)!.group(1)!,
      );

      final int expectedDist =
          (GeoFirePoint(point).distanceBetweenInKm(geopoint: postLocation) *
                  1000)
              .toInt();

      expect(actualDist, expectedDist);
    }

    await AppActions.bottomBarNavigate(NavigationBarRoutes.feed, tester);
    await AppActions.openPost(tester, post.data.title);

    // check that points are given out
    const reward = ChallengeRepositoryService.soloChallengeReward;
    expect(find.byType(SnackBar), findsOne);
    expect(find.textContaining(reward.toString()), findsOne);

    await AppActions.navigateBack(tester);
    await AppActions.navigateToProfile(tester);

    final topBar = find.byType(ProfileAppBar);
    final userPoints = find.descendant(
      of: topBar,
      matching: find.textContaining("$reward Centauri"),
    );
    expect(userPoints, findsOne);
  });

  testWidgets("Commenting on my post", (WidgetTester tester) async {
    await loadProxima(tester);
    await AppActions.loginToCreateAccount(tester);
    await AppActions.createAccountToHome(tester);
    await AppActions.createPost(tester, testPostTitle, testPostDescription);
    await AppActions.expectCommentCount(tester, testPostTitle, 0);

    // Add two comments
    const comments = ["I like turtles too!", "I prefer elephants"];
    for (final (i, comment) in comments.indexed) {
      await AppActions.openPost(tester, testPostTitle);
      await AppActions.addComment(tester, comment);
      await AppActions.navigateBack(tester);
      await AppActions.expectCommentCount(tester, testPostTitle, i + 1);
    }

    // Deleting a comment should reduce the comment count
    await AppActions.deleteComment(tester, comments.first);
    await AppActions.expectCommentCount(tester, testPostTitle, 1);
  });
}
