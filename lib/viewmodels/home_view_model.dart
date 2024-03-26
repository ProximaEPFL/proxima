import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_data.dart";

// This provider is used to store the list of posts that are displayed in the home feed.
final postList = Provider<List<Post>>((ref) {
  return List.empty();
});
