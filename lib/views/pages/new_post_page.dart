import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../viewmodels/new_post_view_model.dart";

class NewPostPage extends HookConsumerWidget {
  const NewPostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(titleProvider);
    final body = ref.watch(bodyProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            Text(body),
          ],
        ),
      ),
    );
  }
}