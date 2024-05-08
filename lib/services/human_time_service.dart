import "package:hooks_riverpod/hooks_riverpod.dart";

/// A function that returns the current date/time as [DateTime]
typedef CurrentDateTimeCallback = DateTime Function();

/// Human Time Service is a service that uses dependency injection
/// to provide related time as a human readable text given a [DateTime]
class HumanTimeService {
  HumanTimeService();
}

final currentDateTimeCallbackProvider =
    Provider<CurrentDateTimeCallback>((ref) {
  return DateTime.now;
});

final humanTimeServiceProvider = Provider<HumanTimeService>((ref) {
  return HumanTimeService();
});
