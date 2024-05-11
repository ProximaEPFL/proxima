import "package:flutter_test/flutter_test.dart";
import "package:proxima/services/conversion/human_time_service.dart";

import "../../mocks/providers/provider_human_time_service.dart";

void main() {
  group("Human Time Service Unit tests", () {
    late HumanTimeService humanTimeService;

    setUp(() {
      // Setup the `HumanTimeService` for constant time
      humanTimeService = HumanTimeService(
        currentDateTimeCallback: constantTimeCallback(),
      );
    });

    test("Check correct simple absolute time", () {
      // Setup actual values for simple date
      final time1 = DateTime.utc(2002);

      const expectedSimpleHumanText = "Tuesday, January 1, 2002 00:00";

      // Use the service to get human time
      final actualSimpleHumanText = humanTimeService.textTimeAbsolute(
        time1,
      );

      // Check that the absolute time value is correct
      expect(
        actualSimpleHumanText,
        expectedSimpleHumanText,
      );
    });

    test("Check correct complex absolute time", () {
      // Setup actual values for complex specific date
      final time2 = DateTime.utc(
        2023,
        11,
        21,
        1,
      );

      const expectedComplexHumanText = "Tuesday, November 21, 2023 01:00";

      // Use the service to get human time
      final actualComplexHumanText = humanTimeService.textTimeAbsolute(
        time2,
      );

      // Check that the specific absolute time value is correct
      expect(
        actualComplexHumanText,
        expectedComplexHumanText,
      );
    });

    test("Check special case 'now' relative time", () {
      // Setup actual relative values for 'now' case
      final closeToNowTime = constantTestingTime.subtract(
        const Duration(seconds: 1),
      );

      const expectedNowRelativeTime = "now";

      // Use the service to get relative human time
      final actualNowTimeHumanText = humanTimeService.textTimeSince(
        closeToNowTime,
      );

      // Check that the time value is correctly 'now'
      expect(
        actualNowTimeHumanText,
        expectedNowRelativeTime,
      );
    });

    test("Check 10 minutes relative time", () {
      // Setup specific time values for 10 min before constant time
      final relative10Minutes = constantTestingTime.subtract(
        const Duration(minutes: 10),
      );

      const expectedRelative10Minutes = "10m ago";

      // Use the service to get relative human time
      final actualMinuteTimeHumanText = humanTimeService.textTimeSince(
        relative10Minutes,
      );

      // Check that the time value is correct for 10 minutes
      expect(
        actualMinuteTimeHumanText,
        expectedRelative10Minutes,
      );
    });

    test("Check 4 days relative time", () {
      // Setup specific time values for 4 days before constant time
      final relative4Days = constantTestingTime.subtract(
        const Duration(days: 4),
      );

      const expectedRelative4Days = "4d ago";

      // Use the service to get relative human time
      final actualDaysTimeHumanText = humanTimeService.textTimeSince(
        relative4Days,
      );

      // Check that the time value is correct for 4 days
      expect(
        actualDaysTimeHumanText,
        expectedRelative4Days,
      );
    });
  });
}
