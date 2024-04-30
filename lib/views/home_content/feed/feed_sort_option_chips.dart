import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/sorting/post_sort_option.dart";
import "package:proxima/viewmodels/feed_sort_options_view_model.dart";

/// This widget is the list of sort options for the timeline.
class FeedSortOptionChips extends ConsumerWidget {
  const FeedSortOptionChips({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOption = ref.watch(feedSortOptionsProvider);

    final sortOptions = PostSortOption.values.map((sortOption) {
      return ChoiceChip(
        selected: sortOption == selectedOption,
        label: Text(sortOption.name),
        onSelected: (value) {
          if (value) {
            ref
                .read(feedSortOptionsProvider.notifier)
                .setSortOption(sortOption);
          }
        },
      );
    }).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: sortOptions,
    );
  }
}
