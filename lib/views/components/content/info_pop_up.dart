import "package:flutter/material.dart";

/// A widget that displays a pop-up with a title, content, and a button.
class InfoPopUp extends StatelessWidget {
  static const popUpTitleKey = Key("profilePopUpTitle");
  static const popUpDescriptionKey = Key("profilePopUpDescription");

  const InfoPopUp({super.key, this.title, this.content, this.button});

  final String? title;
  final String? content;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    // If the title is not null, it will be displayed in a single line.
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

    // If the content is not null, it will be displayed in a scrollable view.
    final potentialDialogContent = content != null
        ? Scrollbar(
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
                  content!,
                ),
              ),
            ),
          )
        : null;

    return AlertDialog(
      title: potentialTitle,
      content: potentialDialogContent,
      contentPadding: EdgeInsets.only(
        left: 24.0,
        top: 8.0,
        right: 24.0,
        bottom: button != null ? 12.0 : 0.0,
      ),
      actionsPadding: const EdgeInsets.only(
        right: 24.0,
        bottom: 12.0,
        left: 24.0,
      ),
      actions: button != null ? [button!] : [],
    );
  }
}
