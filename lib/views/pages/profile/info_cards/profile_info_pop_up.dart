import "package:flutter/material.dart";
import "package:proxima/views/components/delete_button.dart";

class ProfileInfoPopUp extends StatelessWidget {
  static const popUpTitleKey = Key("profilePopUpTitle");
  static const popUpDescriptionKey = Key("profilePopUpDescription");
  static const popUpDeleteButtonKey = Key("profilePopUpDeleteButton");

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
    final potentialTitle = title != null
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              key: popUpTitleKey,
              maxLines: 1,
              title!,
            ),
          )
        : null;

    final dialogContent = Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            right: 8.0,
            left: 8.0,
          ),
          child: Text(
            key: popUpDescriptionKey,
            content,
          ),
        ),
      ),
    );

    final deleteAction = DeleteButton(
      onClick: () async {
        await onDelete();
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );

    return AlertDialog(
      title: potentialTitle,
      content: dialogContent,
      contentPadding: const EdgeInsets.only(
        left: 24.0,
        top: 8.0,
        right: 24.0,
      ),
      actionsPadding: const EdgeInsets.only(
        right: 24.0,
        bottom: 12.0,
        left: 24.0,
      ),
      actions: [deleteAction],
    );
  }
}
