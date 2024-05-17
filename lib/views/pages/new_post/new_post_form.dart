import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/viewmodels/new_post_view_model.dart";
import "package:proxima/views/components/async/circular_value.dart";
import "package:proxima/views/helpers/types.dart";

class NewPostForm extends HookConsumerWidget {
  const NewPostForm({super.key});

  static const titleFieldKey = Key("title");
  static const bodyFieldKey = Key("body");
  static const postButtonKey = Key("post");

  static const _titleHint = "Title";
  static const _bodyHint = "Body";
  static const _postButtonText = "Post";

  Padding _verticallyPadded(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(newPostViewModelProvider, (previous, state) {
      if (state.valueOrNull?.posted == true) {
        Navigator.pop(context);
      }
    });

    final asyncState = ref.watch(newPostViewModelProvider.future).mapRes();

    final titleController = useTextEditingController();
    final bodyController = useTextEditingController();

    return CircularValue(
      future: asyncState,
      builder: (context, state) {
        final titleField = TextField(
          key: titleFieldKey,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: _titleHint,
            errorText: state.titleError,
          ),
          controller: titleController,
        );

        final bodyField = TextField(
          key: bodyFieldKey,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: _bodyHint,
            errorText: state.descriptionError,
          ),
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          controller: bodyController,
        );

        final postButton = ElevatedButton(
          key: postButtonKey,
          child: const Text(_postButtonText),
          onPressed: () => ref.read(newPostViewModelProvider.notifier).addPost(
                titleController.text,
                bodyController.text,
              ),
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

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _verticallyPadded(titleField),
            Flexible(
              fit: FlexFit.loose,
              child: _verticallyPadded(bodyField),
            ),
            _verticallyPadded(buttonRow),
          ],
        );
      },
    );
  }
}
