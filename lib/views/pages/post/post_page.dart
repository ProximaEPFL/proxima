import "package:flutter/material.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";
import "package:proxima/views/pages/post/post_page_widget/bottom_bar_add_comment.dart";
import "package:proxima/views/pages/post/post_page_widget/entire_post_widget.dart";

class PostPage extends StatelessWidget {
  const PostPage({
    super.key,
    required this.postOverview,
  });

  final PostOverview postOverview;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    List<Widget> bodyChildren = [
      EntirePostWidget(post: postOverview),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Wrap(
          runSpacing: 15,
          children: [
            // CommentPostWidget(
            //   comment: "This is a mock comment",
            //   posterUsername: "Comment_poster",
            // ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Post"),
            //TODO: Add distance to post
            Text(
              "50m away",
              style: themeData.textTheme.titleSmall,
            ),
          ],
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
            //TODO: Replace with actual username
            currentDisplayName: "Username",
          ),
        ),
      ],
    );
  }
}
