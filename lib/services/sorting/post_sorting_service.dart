import "package:cloud_firestore/cloud_firestore.dart";
import "package:collection/collection.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_firestore.dart";
import "package:proxima/services/sorting/post_sort_option.dart";

class PostSortingService {
  /// This method sorts the [posts] according to the [option]
  /// and the [position] of the user. Any elements that are in
  /// [putOnTop] will be moreover first in the list.
  /// For instance, let's say that we have a list [A, b, c, D, e]
  /// randomly shuffled that we sort by alphabetical order. If
  /// putOnTop contains [A, D, K], then the result will be
  /// [A, D, b, c, e].
  List<PostFirestore> sort(
    List<PostFirestore> posts,
    PostSortOption option,
    GeoPoint position, {
    Set<PostFirestore> putOnTop = const {},
  }) {
    int defaultComparator(a, b) {
      final order = option
          .scoreFunction(a, position)
          .compareTo(option.scoreFunction(b, position));
      // Multiplying by -1 reverses the order
      final sign = option.sortIncreasing ? 1 : -1;
      return sign * order;
    }

    late final Comparator<PostFirestore> comparator;
    if (putOnTop.isEmpty) {
      // This is a slight optimisation that allows the function
      // to have the expected complexity when putOnTop is empty
      // (though having putOnTop non empty does not change the asymptotic
      // complexity of the function if it is a hash set/of constant size)
      comparator = defaultComparator;
    } else {
      comparator = (a, b) {
        final putOnTopA = putOnTop.contains(a);
        final putOnTopB = putOnTop.contains(b);

        if (putOnTopA && !putOnTopB) {
          // a is considered smaller
          return -1;
        } else if (!putOnTopA && putOnTopB) {
          return 1;
        }

        return defaultComparator(a, b);
      };
    }

    return posts.sorted(comparator);
  }
}

final postSortingServiceProvider = Provider<PostSortingService>(
  (ref) => PostSortingService(),
);
