import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/human_time_service.dart";

CurrentDateTimeCallback constantTimeCallback() {
  return () => DateTime.utc(2000);
}

final constantDateTimeCallbackProvider =
    Provider<CurrentDateTimeCallback>((ref) {
  return constantTimeCallback();
});

final constantHumanTimeServiceProvider = Provider<HumanTimeService>((ref) {
  final currentDateTimeCallback = ref.watch(constantDateTimeCallbackProvider);

  return HumanTimeService(
    currentDateTimeCallback: currentDateTimeCallback,
  );
});
