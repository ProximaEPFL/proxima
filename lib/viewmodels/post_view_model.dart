import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/comment_post.dart";

// This provider is used to store the list of comments that are displayed in the post page.
final commentListProvider = Provider<List<CommentPost>>((ref) {
  return List.empty();
});
