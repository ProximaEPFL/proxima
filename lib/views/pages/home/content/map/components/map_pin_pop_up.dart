import "package:flutter/material.dart";

class MapPinPopUp extends StatelessWidget {
  //key for the arrow button
  static const arrowButtonKey = Key("arrowButton");
  const MapPinPopUp({
    super.key,
    this.title,
    this.content,
    this.navigationAction,
  });

  final String? title;
  final String? content;
  final void Function()? navigationAction;

  @override
  Widget build(BuildContext context) {
    final potentialTitle = title != null
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              maxLines: 1,
              title!,
            ),
          )
        : null;

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
                  content!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ),
          )
        : null;

    final arrowAction = IconButton(
      key: arrowButtonKey,
      icon: const Icon(Icons.arrow_forward),
      onPressed: navigationAction,
    );

    return AlertDialog(
      title: potentialTitle,
      content: potentialDialogContent,
      contentPadding: EdgeInsets.only(
        left: 24.0,
        top: 8.0,
        right: 24.0,
        bottom: navigationAction != null ? 12.0 : 0.0,
      ),
      actionsPadding: const EdgeInsets.only(
        right: 24.0,
        bottom: 12.0,
        left: 24.0,
      ),
      actions: navigationAction != null ? [arrowAction] : null,
    );
  }
}
