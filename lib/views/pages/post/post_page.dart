import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/post_details.dart";
import "package:proxima/viewmodels/comments_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/post/post_page_widget/bottom_bar_add_comment.dart";
import "package:proxima/views/pages/post/post_page_widget/comment_list.dart";
import "package:proxima/views/pages/post/post_page_widget/complete_post_widget.dart";

class PostPage extends HookConsumerWidget {
  static const postDistanceKey = Key("postDistance");
  static const completePostWidgetKey = Key("completePostWidget");
  static const commentListWidgetKey = Key("commentListWidget");
  static const bottomBarAddCommentKey = Key("bottomBarAddComment");

  static const _appBarTitle = "Post";

  const PostPage({
    super.key,
    required this.postDetails,
  });

  final PostDetails postDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeData themeData = Theme.of(context);

    final commentsAsync = ref.watch(commentsViewModelProvider(postDetails.postId));

    // Top app bar content = Title + Distance
    List<Widget> appBarContent = [
      const Text(_appBarTitle),
      Text(
        "${postDetails.distance}m away",
        key: postDistanceKey,
        style: themeData.textTheme.titleSmall,
      ),
    ];

    // Body = Complete post + Comments
    List<Widget> bodyChildren = [
      CompletePostWidget(
        key: completePostWidgetKey,
        post: postDetails,
      ),
      const SizedBox(height: 10),
      CircularValue(
        value: commentsAsync,
        builder: (context, comments) => CommentList(
          key: commentListWidgetKey,
          comments: comments,
        ),
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
          child: RefreshIndicator(
            onRefresh: ref
                .read(commentsViewModelProvider(postDetails.postId).notifier)
                .refresh,
            child: ListView(
              children: bodyChildren,
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding:
              // This is necessary to prevent the keyboard from covering the bottom bar
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: BottomBarAddComment(
            key: bottomBarAddCommentKey,
            parentPostId: postDetails.postId,
          ),
        ),
      ],
    );
  }
}
