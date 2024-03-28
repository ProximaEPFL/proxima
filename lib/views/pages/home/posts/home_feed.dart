import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/home_view_model.dart";
import "package:proxima/views/filter_widgets/timeline_filter/timeline_filter_dropdown.dart";
import "package:proxima/views/pages/home/posts/post_card/post_card.dart";

/// This widget is the feed of the home page
/// It contains the posts
class HomeFeed extends HookConsumerWidget {
  static const timelineFiltersDropDownKey = Key("timelineFiltersDropDown");
  static const homeFeedKey = Key("homeFeed");
  static const emptyHomeFeedKey = Key("emptyHomeFeed");
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postList);
    List<Widget> widgetChildren = [];

    widgetChildren.add(
      const TimeLineFiltersDropDown(
        key: timelineFiltersDropDownKey,
      ),
    );
    widgetChildren.add(const Divider());

    if (posts.isEmpty) {
      widgetChildren.add(Flexible(flex: 1, child: Container()));
      widgetChildren.add(
        _buildeEmptyFeed(),
      );
      widgetChildren.add(Flexible(flex: 1, child: Container()));
      return Column(
        children: widgetChildren,
      );
    } else {
      widgetChildren.addAll(_buildFeed(ref));
      return ListView(
        key: homeFeedKey,
        children: widgetChildren,
      );
    }
  }

  Widget _buildeEmptyFeed() {
    return Center(
      key: emptyHomeFeedKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No post to display, "),
          InkWell(
            onTap: () => {
              //TODO: Add navigation to create post page
            },
            child: const Text(
              "create one",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeed(WidgetRef ref) {
    final posts = ref.watch(postList);
    return posts.map((post) => PostCard(post: post)).toList();
  }
}
