import "package:proxima/services/human_time_service.dart";

CurrentDateTimeCallback constantTimeCallback() {
  return () => DateTime.utc(2000);
}
