import "package:flutter_test/flutter_test.dart";
import "package:proxima/services/human_time_service.dart";

import "../mocks/providers/provider_human_time_service.dart";

void main() {
  group("Human Time Service Unit tests", () {
    late HumanTimeService humanTimeService;

    setUp(() {
      humanTimeService =
          HumanTimeService(currentDateTimeCallback: constantTimeCallback());
    });

    test("Check correct absolute time 1", () {});
  });
}
