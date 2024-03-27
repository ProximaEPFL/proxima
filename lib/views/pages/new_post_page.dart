import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

class NewPostPage extends HookConsumerWidget {
  const NewPostPage({super.key});

  static const backButtonKey = Key("back");

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
        child: NewPostForm(),
      ),
    );
  }
}

class NewPostForm extends HookConsumerWidget {
  NewPostForm({super.key});

  static const titleFieldKey = Key("title");
  static const bodyFieldKey = Key("body");

  static const titleHint = "Title";
  static const bodyHint = "Body";
  static const postButtonText = "Post";

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: TextFormField(
              key: titleFieldKey,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: titleHint,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a title";
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: TextFormField(
              key: bodyFieldKey,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: bodyHint,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a body";
                }
                return null;
              },
              minLines: 5,
              maxLines: 9,
              // TODO make this flexible based on the screen size
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text(postButtonText),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      // TODO commit the post to the repository

                      Navigator.pop(context);
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
        ],
      ),
    );
  }
}
