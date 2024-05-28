import "package:flutter/material.dart";
import "package:proxima/views/components/async/loading_icon_button.dart";
import "package:proxima/views/components/content/info_pop_up.dart";
import "package:proxima/views/helpers/types/future_void_callback.dart";
import "package:proxima/views/navigation/map_action.dart";

class ProfileInfoPopUp extends StatelessWidget {
  //key of the button
  static const popUpButtonKey = Key("profilePopUpButton");

  const ProfileInfoPopUp({
    super.key,
    this.title,
    required this.content,
    required this.onDelete,
  });

  final String? title;
  final String content;
  final FutureVoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final deleteAction = DeleteButton(
      key: popUpButtonKey,
      onClick: () async {
        await onDelete();
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );

    const mapAction = MapAction(depth: 2);

    return InfoPopUp(
      title: title,
      content: content,
      actions: [mapAction, deleteAction],
    );
  }
}
