import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:proxima/views/components/async/loading_icon_button.dart";
import "package:proxima/views/components/content/info_pop_up.dart";
import "package:proxima/views/components/options/map/map_selection_options.dart";
import "package:proxima/views/helpers/types/future_void_callback.dart";
import "package:proxima/views/navigation/map_action.dart";

class ProfileInfoPopUp extends StatelessWidget {
  //key of the button
  static const popUpButtonKey = Key("profilePopUpButton");

  const ProfileInfoPopUp({
    super.key,
    this.title,
    this.location,
    required this.content,
    required this.onDelete,
  });

  final String? title;
  final GeoPoint? location;
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

    List<Widget> actions = [deleteAction];
    if (location != null) {
      actions.insert(
        0,
        MapAction(
          depth: 2,
          mapOption: MapSelectionOptions.myPosts,
          initialLocation: location!,
        ),
      );
    }

    return InfoPopUp(
      title: title,
      content: content,
      actions: actions,
    );
  }
}
