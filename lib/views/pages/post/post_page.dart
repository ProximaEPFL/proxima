import "package:flutter/material.dart";
import "package:proxima/models/ui/post_overview.dart";
import "package:proxima/views/navigation/leading_back_button/leading_back_button.dart";

class PostPage extends StatelessWidget {
  const PostPage({
    super.key,
    required this.postOverview,
  });

  final PostOverview postOverview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBackButton(),
        title: const Text("Post"),
      ),
      body: Center(
        child: Text(postOverview.title),
      ),
    );
  }
}
