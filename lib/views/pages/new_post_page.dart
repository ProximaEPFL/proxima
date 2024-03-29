import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

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

class NewPostForm extends HookConsumerWidget {
  NewPostForm({super.key});

  static const titleFieldKey = Key("title");
  static const bodyFieldKey = Key("body");
  static const postButtonKey = Key("post");

  static const _titleHint = "Title";
  static const _bodyHint = "Body";
  static const _postButtonText = "Post";

  static const _titleError = "Please enter a title";
  static const _bodyError = "Please enter a body";

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleField = TextFormField(
      key: titleFieldKey,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: _titleHint,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _titleError;
        }
        return null;
      },
    );

    final bodyField = TextFormField(
      key: bodyFieldKey,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: _bodyHint,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _bodyError;
        }
        return null;
      },
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
    );

    final postButton = ElevatedButton(
      key: postButtonKey,
      child: const Text(_postButtonText),
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          // TODO commit the post to the repository
          Navigator.pop(context);
        }
      },
    );

    final settingsButton = IconButton(
      onPressed: () {
        // TODO open tag and notification settings overlay
      },
      icon: const Icon(Icons.settings),
    );

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: titleField,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: bodyField,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: postButton),
                settingsButton,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
