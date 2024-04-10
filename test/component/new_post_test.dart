import "package:cloud_firestore/cloud_firestore.dart";
import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/user/user_firestore.dart";
import "package:proxima/models/login_user.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/database/user_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/new_post/new_post_form.dart";
import "package:proxima/views/pages/new_post/new_post_page.dart";

import "../services/database/mock_post_repository_service.dart";
import "../services/firebase/setup_firebase_mocks.dart";
import "../services/firestore/testing_firestore_provider.dart";
import "../services/mock_geo_location_service.dart";
import "../services/test_data/firebase_auth_user_mock.dart";
import "../services/test_data/firestore_user_mock.dart";

void main() {
  setupFirebaseAuthMocks();
  MockPostRepositoryService postRepository = MockPostRepositoryService();
  MockGeoLocationService geoLocationService = MockGeoLocationService();

  Stream<LoginUser?> fakeUserProvider() async* {
    yield LoginUser(
      id: testingLoginUser.uid,
      email: testingLoginUser.email,
    );
  }

  final mockedPage = ProviderScope(
    overrides: firebaseMocksOverrides +
        [
          postRepositoryProvider.overrideWithValue(postRepository),
          geoLocationServiceProvider.overrideWithValue(geoLocationService),
          userProvider.overrideWith((ref) => fakeUserProvider()),
        ],
    child: const MaterialApp(
      home: NewPostPage(),
    ),
  );

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets("Create post contains title, body and post button",
      (tester) async {
    await tester.pumpWidget(mockedPage);
    await tester.pumpAndSettle();

    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    final bodyFinder = find.byKey(NewPostForm.bodyFieldKey);
    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);

    expect(titleFinder, findsOneWidget);
    expect(bodyFinder, findsOneWidget);
    expect(postButtonFinder, findsOneWidget);
  });

  testWidgets("Back button works", (widgetTester) async {
    await widgetTester.pumpWidget(mockedPage);
    await widgetTester.pumpAndSettle();

    final backButton = find.byKey(LeadingBackButton.leadingBackButtonKey);
    await widgetTester.tap(backButton);
    await widgetTester.pumpAndSettle();

    // check that we are no longer on the new post page
    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    expect(titleFinder, findsNothing);
  });

  testWidgets("Accepts non empty post", (widgetTester) async {
    await widgetTester.pumpWidget(mockedPage);
    await widgetTester.pumpAndSettle();

    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    await widgetTester.enterText(titleFinder, "I like turtles");
    await widgetTester.pumpAndSettle();

    final bodyFinder = find.byKey(NewPostForm.bodyFieldKey);
    await widgetTester.enterText(bodyFinder, "Look at them go!");
    await widgetTester.pumpAndSettle();

    GeoPoint testPoint = const GeoPoint(0, 0);
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(testPoint),
    );

    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    // check that we are no longer on the new post page
    expect(titleFinder, findsNothing);
  });

  testWidgets("Writes post to repository", (widgetTester) async {
    await widgetTester.pumpWidget(mockedPage);
    await widgetTester.pumpAndSettle();

    GeoPoint testPoint = const GeoPoint(0, 0);
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(testPoint),
    );

    PostData postData = PostData(
      ownerId: testingUserFirestoreId,
      title: "I like turtles",
      description: "Look at them go!",
      publicationTime: Timestamp.now(),
      voteScore: 0,
    );

    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    await widgetTester.enterText(titleFinder, postData.title);
    await widgetTester.pumpAndSettle();

    final bodyFinder = find.byKey(NewPostForm.bodyFieldKey);
    await widgetTester.enterText(bodyFinder, postData.description);
    await widgetTester.pumpAndSettle();

    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    verify(postRepository.addPost(postData, testPoint)).called(1);
  });

  testWidgets("Refuses empty post", (widgetTester) async {
    await widgetTester.pumpWidget(mockedPage);
    await widgetTester.pumpAndSettle();

    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    // check that we are still on the new post page
    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    expect(titleFinder, findsOne);
  });
}
