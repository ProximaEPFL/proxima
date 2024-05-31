import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/sorting/post/post_sort_option.dart";
import "package:proxima/viewmodels/option_selection/options_view_model.dart";

/// The view model for the sort options of the feed
class FeedSortOptionsViewModel extends OptionsViewModel<PostSortOption> {
  static const defaultSortOption = PostSortOption.hottest;

  FeedSortOptionsViewModel() : super(defaultSortOption);
}

final feedSortOptionsViewModelProvider =
    NotifierProvider<FeedSortOptionsViewModel, PostSortOption>(
  () => FeedSortOptionsViewModel(),
);
