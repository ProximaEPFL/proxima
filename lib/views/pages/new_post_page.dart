import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class NewPostPage extends HookConsumerWidget {
  const NewPostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a new post"),
        leading: IconButton(
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
                  hintText: "Title",
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Body",
                ),
                minLines: 5,
                maxLines: 10, // TODO make this depend on the screen size
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                child: const Text("Post"),
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
      ),
    );
  }
}
