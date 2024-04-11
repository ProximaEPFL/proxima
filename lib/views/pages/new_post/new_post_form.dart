import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/services/database/post_repository_service.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/utils/ui/circular_value.dart";
import "package:proxima/viewmodels/login_view_model.dart";
import "package:proxima/viewmodels/new_post_view_model.dart";

class NewPostForm extends HookConsumerWidget {
  NewPostForm({super.key});

  static const titleFieldKey = Key("title");
  static const bodyFieldKey = Key("body");
  static const postButtonKey = Key("post");

  static const _titleHint = "Title";
  static const _bodyHint = "Body";
  static const _postButtonText = "Post";

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

    final asyncState = ref.watch(newPostStateProvider);

    return CircularValue(
      value: asyncState,
      builder: (context, state) {
        var titleField = TextField(
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
          onPressed: () async {
            await ref.read(newPostStateProvider.notifier).addPost(
                  titleController.text,
                  bodyController.text,
                );

            if(context.mounted){
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

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            verticallyPadded(titleField),
            Flexible(
              fit: FlexFit.loose,
              child: verticallyPadded(bodyField),
            ),
            verticallyPadded(buttonRow),
          ],
        );
      },
    );
  }
}
