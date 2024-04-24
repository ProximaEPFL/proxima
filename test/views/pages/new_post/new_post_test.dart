import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/new_post/new_post_form.dart";

import "../../../mocks/data/geopoint.dart";
import "../../../mocks/data/post_data.dart";
import "../../../mocks/providers/provider_new_post_page.dart";
import "../../../mocks/services/mock_geo_location_service.dart";
import "../../../mocks/services/mock_post_repository_service.dart";
import "../../../mocks/services/setup_firebase_mocks.dart";

void main() {
  late ProviderScope mockedNewPostPage;
  late MockPostRepositoryService postRepository;
  late MockGeoLocationService geoLocationService;

  const timeDeltaMils = 500;

  setUp(() async {
    setupFirebaseAuthMocks();
    postRepository = MockPostRepositoryService();
    geoLocationService = MockGeoLocationService();
    mockedNewPostPage = newPostPageProvider(postRepository, geoLocationService);
  });

  group("Widgets display", () {
    testWidgets("Display title, body, post button and back button",
        (tester) async {
      await tester.pumpWidget(mockedNewPostPage);
      await tester.pumpAndSettle();

      final titleFinder = find.byKey(NewPostForm.titleFieldKey);
      final bodyFinder = find.byKey(NewPostForm.bodyFieldKey);
      final postButtonFinder = find.byKey(NewPostForm.postButtonKey);
      final backButton = find.byKey(LeadingBackButton.leadingBackButtonKey);

      expect(titleFinder, findsOneWidget);
      expect(bodyFinder, findsOneWidget);
      expect(postButtonFinder, findsOneWidget);
      expect(backButton, findsOneWidget);
    });
  });

  testWidgets("Back button navigation", (widgetTester) async {
    await widgetTester.pumpWidget(mockedNewPostPage);
    await widgetTester.pumpAndSettle();

    final backButton = find.byKey(LeadingBackButton.leadingBackButtonKey);
    await widgetTester.tap(backButton);
    await widgetTester.pumpAndSettle();

    // check that we are no longer on the new post page
    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    expect(titleFinder, findsNothing);
  });

  testWidgets("Writes non empty post to repository", (widgetTester) async {
    await widgetTester.pumpWidget(mockedNewPostPage);
    await widgetTester.pumpAndSettle();

    GeoPoint testPoint = userPosition0;
    when(geoLocationService.getCurrentPosition()).thenAnswer(
      (_) => Future.value(testPoint),
    );

    PostData postData = PostDataGenerator().postData;

    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    await widgetTester.enterText(titleFinder, postData.title);
    await widgetTester.pumpAndSettle();

    final bodyFinder = find.byKey(NewPostForm.bodyFieldKey);
    await widgetTester.enterText(bodyFinder, postData.description);
    await widgetTester.pumpAndSettle();

    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);

    when(postRepository.addPost(any, any)).thenAnswer((_) {
      return Future.value(const PostIdFirestore(value: "id"));
    });

    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    final PostData capturedPostData =
        verify(postRepository.addPost(captureAny, testPoint)).captured.first;

    expect(capturedPostData.title, postData.title);
    expect(capturedPostData.description, postData.description);
    expect(capturedPostData.ownerId, postData.ownerId);
    expect(capturedPostData.voteScore, postData.voteScore);

    // check that the publication time is within a reasonable delta
    expect(
      capturedPostData.publicationTime.millisecondsSinceEpoch,
      closeTo(
        postData.publicationTime.millisecondsSinceEpoch,
        timeDeltaMils,
      ),
    );

    expect(titleFinder, findsNothing);
  });

  testWidgets("Refuses empty post", (widgetTester) async {
    await widgetTester.pumpWidget(mockedNewPostPage);
    await widgetTester.pumpAndSettle();

    final postButtonFinder = find.byKey(NewPostForm.postButtonKey);
    await widgetTester.tap(postButtonFinder);
    await widgetTester.pumpAndSettle();

    // check that we are still on the new post page
    final titleFinder = find.byKey(NewPostForm.titleFieldKey);
    expect(titleFinder, findsOne);
  });
}
