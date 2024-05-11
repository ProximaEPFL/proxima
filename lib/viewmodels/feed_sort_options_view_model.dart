import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/sorting/post/post_sort_option.dart";

/// The view model for the sort options of the feed
class FeedSortOptionsViewModel extends Notifier<PostSortOption> {
  static const defaultSortOption = PostSortOption.hottest;

  @override
  PostSortOption build() {
    return defaultSortOption;
  }

  void setSortOption(PostSortOption sortOption) {
    state = sortOption;
  }
}

final feedSortOptionsProvider =
    NotifierProvider<FeedSortOptionsViewModel, PostSortOption>(
  () => FeedSortOptionsViewModel(),
);
