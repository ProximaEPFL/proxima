

import "package:hooks_riverpod/hooks_riverpod.dart";

final titleProvider = Provider<String>((ref) {
  return "New Post";
});

final bodyProvider = Provider<String>((ref) {
  return "This is a new post.";
});

