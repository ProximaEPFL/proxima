import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:proxima/views/pages/new_post/new_post_form.dart";

class NewPostPage extends HookConsumerWidget {
  const NewPostPage({super.key});

  static const backButtonKey = Key("back");
  static const _pageTitle = "Create a new post";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_pageTitle),
        leading: IconButton(
          key: backButtonKey,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: NewPostForm(),
      ),
    );
  }
}
