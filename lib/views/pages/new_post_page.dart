import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class NewPostPage extends HookConsumerWidget {
  const NewPostPage({super.key});

  static const backButtonKey = Key("back");

  static const titleHint = "Title";
  static const bodyHint = "Body";
  static const postButtonText = "Post";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a new post"),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: titleHint,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: bodyHint,
                ),
                minLines: 5,
                maxLines: 10, // TODO make this depend on the screen size
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text(postButtonText),
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO commit the post to the repository
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO open tag and notification settings overlay
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
