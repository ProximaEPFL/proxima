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

    test("Check correct absolute time 1", () {
      final time1 = DateTime.utc(2002);
      const expectedHumanText = "Tuesday, January 1, 2002 00:00";

      final actualHumanText = humanTimeService.textTimeAbsolute(time1);
      expect(
        actualHumanText,
        expectedHumanText,
      );
      // humanTimeService.
    });
  });
}
