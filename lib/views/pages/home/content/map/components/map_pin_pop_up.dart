import "package:flutter/material.dart";
import "package:proxima/views/components/content/info_pop_up.dart";

class MapPinPopUp extends StatelessWidget {
  //key of the button
  static const popUpButtonKey = Key("mapPinPopUpButton");

  const MapPinPopUp({
    super.key,
    required this.title,
    this.content,
    this.navigationAction,
  });

  final String title;
  final String? content;
  final void Function()? navigationAction;

  @override
  Widget build(BuildContext context) {
    final arrowAction = IconButton(
      key: popUpButtonKey,
      icon: const Icon(Icons.arrow_forward),
      onPressed: navigationAction,
    );

    return InfoPopUp(
      title: title,
      content: content,
      button: arrowAction,
    );
  }
}
