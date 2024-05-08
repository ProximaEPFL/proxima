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

      final actualNowTimeHumanText = humanTimeService.textTimeSince(
        nowTime,
      );

      expect(actualNowTimeHumanText, "now");
    });
  });
}
