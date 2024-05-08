import "package:flutter_test/flutter_test.dart";
import "package:proxima/services/human_time_service.dart";

import "../mocks/providers/provider_human_time_service.dart";

void main() {
  group("Human Time Service Unit tests", () {
    late HumanTimeService humanTimeService;

    setUp(() {
      humanTimeService = HumanTimeService(
        currentDateTimeCallback: constantTimeCallback(),
      );
    });

    test("Check correct simple absolute time", () {
      final time1 = DateTime.utc(2002);
      const expectedSimpleHumanText = "Tuesday, January 1, 2002 00:00";

      final actualSimpleHumanText = humanTimeService.textTimeAbsolute(
        time1,
      );

      expect(
        actualSimpleHumanText,
        expectedSimpleHumanText,
      );
    });

    test("Check correct complex absolute time", () {
      final time2 = DateTime.utc(
        2023,
        11,
        21,
        1,
      );

      const expectedComplexHumanText = "Tuesday, November 21, 2023 01:00";

      final actualComplexHumanText = humanTimeService.textTimeAbsolute(
        time2,
      );

      expect(
        actualComplexHumanText,
        expectedComplexHumanText,
      );
    });

    test("Check special case 'now' relative time", () {
      final nowTime = constantTestingTime.add(const Duration(seconds: 1));

      const expectedNowRelativeTime = "now";

      final actualNowTimeHumanText = humanTimeService.textTimeSince(
        nowTime,
      );

      expect(
        actualNowTimeHumanText,
        expectedNowRelativeTime,
      );
    });

    test("Check 10 minutes relative time", () {
      final relative10Minutes = constantTestingTime.subtract(
        const Duration(minutes: 10),
      );

      const expectedRelative10Minutes = "10m ago";

      final actualMinuteTimeHumanText = humanTimeService.textTimeSince(
        relative10Minutes,
      );

      expect(
        actualMinuteTimeHumanText,
        expectedRelative10Minutes,
      );
    });

    test("Check 4 days relative time", () {
      final relative4Days = constantTestingTime.subtract(
        const Duration(days: 4),
      );

      const expectedRelative4Days = "4d ago";

      final actualDaysTimeHumanText = humanTimeService.textTimeSince(
        relative4Days,
      );

      expect(
        actualDaysTimeHumanText,
        expectedRelative4Days,
      );
    });
  });
}
