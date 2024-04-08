import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/database/post/post_data.dart";
import "package:proxima/viewmodels/new_post_view_model.dart";

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

  Padding verticallyPadded(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final bodyController = useTextEditingController();

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
      controller: titleController,
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
      controller: bodyController,
    );

    final postButton = ElevatedButton(
      key: postButtonKey,
      child: const Text(_postButtonText),
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          addPost(titleController.text, bodyController.text, ref);
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

    final buttonRow = Row(
      children: [
        Expanded(child: postButton),
        settingsButton,
      ],
    );

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          verticallyPadded(titleField),
          Flexible(
            fit: FlexFit.loose,
            child: verticallyPadded(bodyField),
          ),
          verticallyPadded(buttonRow),
        ],
      ),
    );
  }
}
