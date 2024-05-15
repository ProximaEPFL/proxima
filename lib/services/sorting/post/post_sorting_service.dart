import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/models/database/post/post_id_firestore.dart";
import "package:proxima/services/sorting/post/post_sort_option.dart";

class PostSortingService {
  /// This method sorts the [posts] according to the [option]
  /// and the [position] of the user. Any elements that are in
  /// [putOnTop] will be moreover first in the list.
  /// For instance, let's say that we have a list of posts with
  /// ids [A, b, c, D, e] randomly shuffled that we sort by alphabetical
  /// order. If putOnTop contains the ids [A, D, K], then the result will
  /// be posts with ids [A, D, b, c, e].
  List<PostFirestore> sort(
    List<PostFirestore> posts,
    PostSortOption option,
    GeoPoint position, {
    Set<PostIdFirestore> putOnTop = const {},
  }) {
    int defaultComparator(PostFirestore postA, PostFirestore postB) {
      final order = option
          .scoreFunction(postA, position)
          .compareTo(option.scoreFunction(postB, position));
      // Multiplying by -1 reverses the order
      final sign = option.sortIncreasing ? 1 : -1;

      return sign * order;
    }

    int putOnTopComparator(PostFirestore a, PostFirestore b) {
      final putOnTopA = putOnTop.contains(a.id);
      final putOnTopB = putOnTop.contains(b.id);

      if (putOnTopA && !putOnTopB) {
        // a is considered smaller
        return -1;
      } else if (!putOnTopA && putOnTopB) {
        return 1;
      }

      return defaultComparator(a, b);
    }

    final comparator =
        putOnTop.isEmpty ? defaultComparator : putOnTopComparator;

    return posts.sorted(comparator);
  }
}

final postSortingServiceProvider = Provider<PostSortingService>(
  (ref) => PostSortingService(),
);
