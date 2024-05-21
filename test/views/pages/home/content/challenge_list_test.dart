import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:mockito/mockito.dart";
import "package:proxima/services/sensors/geolocation_service.dart";
import "package:proxima/views/components/async/error_alert.dart";
import "package:proxima/views/pages/home/content/challenge/challenge_card.dart";
import "package:proxima/views/pages/home/content/challenge/challenge_list.dart";

import "../../../../mocks/data/challenge_list.dart";
import "../../../../mocks/data/geopoint.dart";
import "../../../../mocks/overrides/override_auth_providers.dart";
import "../../../../mocks/overrides/override_firestore.dart";
import "../../../../mocks/providers/provider_challenge.dart";
import "../../../../mocks/services/mock_geo_location_service.dart";
import "../../../../testutils/expect_rich_text.dart";

void main() {
  group(
    "Static testing",
    () {
      testWidgets(
        "Check that there is the correct number of cards, with the correct icons",
        (tester) async {
          const data = mockChallengeList;

          await tester.pumpWidget(mockedChallengeListProvider);
          await tester.pumpAndSettle();

          expect(find.byType(ChallengeList), findsOneWidget);
          expect(find.byType(ChallengeCard), findsNWidgets(data.length));

          final nGroupChallenge =
              data.where((challenge) => challenge.isGroupChallenge).length;
          expect(
            find.byKey(ChallengeCard.challengeGroupIconKey),
            findsNWidgets(nGroupChallenge),
          );

          final nSingleChallenge =
              data.where((challenge) => !challenge.isGroupChallenge).length;
          expect(
            find.byKey(ChallengeCard.challengeSingleIconKey),
            findsNWidgets(nSingleChallenge),
          );

          // Challenges can either be single or group
          expect(nSingleChallenge + nGroupChallenge, data.length);
        },
      );

      testWidgets("Check that the correct data is displayed", (tester) async {
        await tester.pumpWidget(mockedChallengeListProvider);
        await tester.pumpAndSettle();

        for (final challenge in mockChallengeList) {
          expect(find.text(challenge.title), findsOneWidget);

          if (challenge.isFinished) {
            expectRichText("Challenged finished!", findsAtLeastNWidgets(1));
          } else {
            expectRichText(
              "Distance to post: ${challenge.distance} meters",
              findsOneWidget,
            );
          }
          expectRichText(
            "Reward: ${challenge.reward} Centauri",
            findsOneWidget,
          );

          if (!challenge.isGroupChallenge) {
            expectRichText(
              "Time left: ${challenge.timeLeft} hours",
              findsOneWidget,
            );
          }
        }
      });

      testWidgets("Check how errors are handled", (tester) async {
        final geoLocationService = MockGeolocationService();
        final error = Exception("Location services are disabled.");
        when(geoLocationService.getCurrentPosition()).thenThrow(error);

        final provider = ProviderScope(
          overrides: [
            geolocationServiceProvider.overrideWithValue(geoLocationService),
            ...firebaseMocksOverrides,
            ...firebaseAuthMocksOverrides,
          ],
          child: const MaterialApp(home: ChallengeList()),
        );

        await tester.pumpWidget(provider);
        await tester.pumpAndSettle();

        final popup = find.byType(AlertDialog);
        expect(popup, findsOne);

        await tester.tap(find.byKey(ErrorAlert.okButtonKey));
        await tester.pumpAndSettle();

        final refreshButton = find.text("Refresh");
        expect(refreshButton, findsOneWidget);

        when(geoLocationService.getCurrentPosition()).thenAnswer(
          (_) => Future.value(userPosition0),
        );

        await tester.tap(refreshButton);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      });
    },
  );
}
