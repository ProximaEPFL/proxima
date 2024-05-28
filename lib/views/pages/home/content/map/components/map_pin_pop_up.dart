import "package:flutter/material.dart";
import "package:proxima/models/ui/map_pop_up_details.dart";
import "package:proxima/views/components/content/info_pop_up.dart";

class MapPinPopUp extends StatelessWidget {
  //key of the button
  static const popUpButtonKey = Key("mapPinPopUpButton");

  const MapPinPopUp({
    super.key,
    required this.mapPinPopUpDetails,
  });

  final MapPopUpDetails mapPinPopUpDetails;

  @override
  Widget build(BuildContext context) {
    late final IconButton? arrowAction;
    if (mapPinPopUpDetails.route != null) {
      void navigationAction() {
        Navigator.of(context).pushNamed(
          mapPinPopUpDetails.route!,
          arguments: mapPinPopUpDetails.routeArguments,
        );
      }

      arrowAction = IconButton(
        key: popUpButtonKey,
        icon: const Icon(Icons.arrow_forward),
        onPressed: navigationAction,
      );
    } else {
      arrowAction = null;
    }

    return InfoPopUp(
      title: mapPinPopUpDetails.title,
      content: mapPinPopUpDetails.description,
      actions: [arrowAction as Widget],
    );
  }
}
