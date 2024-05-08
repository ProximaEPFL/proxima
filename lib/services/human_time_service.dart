import "package:hooks_riverpod/hooks_riverpod.dart";

class HumanTimeService {
  HumanTimeService();
}

final humanTimeServiceProvider = Provider<HumanTimeService>((ref) {
  return HumanTimeService();
});
