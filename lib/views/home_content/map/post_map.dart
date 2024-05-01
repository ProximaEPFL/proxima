import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:proxima/models/ui/map_info.dart";
import "package:proxima/services/geolocation_service.dart";
import "package:proxima/viewmodels/map_view_model.dart";

class PostMap extends ConsumerWidget {
  final MapInfo mapInfo;
  static const initialZoomLevel = 17.5;

  static const postMapKey = Key("postMap");

  const PostMap({
    super.key,
    required this.mapInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = ref.watch(liveLocationServiceProvider);
    final positionNotifier = ref.watch(mapProvider.notifier);

    currentPosition.when(
      data: (data) {
        debugPrint("Live location: ${data!.latitude}, ${data.longitude}");
        positionNotifier.animateCamera(LatLng(data.latitude, data.longitude));
        positionNotifier.redrawCircle(LatLng(data.latitude, data.longitude));
      },
      error: (error, _) {
        throw Exception("Live location error: $error");
      },
      loading: () => (),
    );

    return Expanded(
      child: GoogleMap(
        key: postMapKey,
        mapType: MapType.normal,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        initialCameraPosition: CameraPosition(
          target: mapInfo.currentLocation,
          zoom: initialZoomLevel,
        ),
        circles: positionNotifier.circles,
        onMapCreated: positionNotifier.onMapCreated,
      ),
    );
  }
}
