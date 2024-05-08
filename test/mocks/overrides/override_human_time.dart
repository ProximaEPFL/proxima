import "package:proxima/services/human_time_service.dart";

import "../providers/provider_human_time_service.dart";

final humanTimeServiceOverride = [
  humanTimeServiceProvider.overrideWith(
    (ref) => ref.watch(constantHumanTimeServiceProvider),
  ),
];
