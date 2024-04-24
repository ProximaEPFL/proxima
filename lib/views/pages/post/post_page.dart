import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/viewmodels/post_view_model.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/post/post_page_widget/bottom_bar_add_comment.dart";
import "package:proxima/views/pages/post/post_page_widget/comment_list.dart";
import "package:proxima/views/pages/post/post_page_widget/complete_post_widget.dart";

class PostPage extends HookConsumerWidget {
  static const postDistanceKey = Key("postDistance");
  static const completePostWidgetKey = Key("completePostWidget");
  static const commentListWidgetKey = Key("commentListWidget");
  static const bottomBarAddCommentKey = Key("bottomBarAddComment");

  const PostPage({
    super.key,
    required this.postOverview,
  });

  final PostOverview postOverview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeData themeData = Theme.of(context);

    final comments = ref.watch(commentListProvider);

    List<Widget> appBarContent = [
      const Text("Post"),
      Text(
        key: postDistanceKey,
        //TODO: Add distance to post
        "50m away",
        style: themeData.textTheme.titleSmall,
      ),
    ];

    List<Widget> bodyChildren = [
      CompletePostWidget(
        key: completePostWidgetKey,
        post: postOverview,
      ),
      const SizedBox(height: 10),
      CommentList(
        key: commentListWidgetKey,
        comments: comments,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: appBarContent,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
        child: Center(
          child: ListView(
            children: bodyChildren,
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding:
              // This is necessary to prevent the keyboard from covering the bottom bar
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const BottomBarAddComment(
            key: bottomBarAddCommentKey,
            //TODO: Replace with actual username
            currentDisplayName: "Username",
          ),
        ),
      ],
    );
  }
}
