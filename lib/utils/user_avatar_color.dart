import "package:flutter/material.dart";
import "package:proxima/models/ui/linear_segmented_hsv_colormap.dart";
import "package:proxima/services/database/challenge_repository_service.dart";

/// Stops for the colormap used to color the user's avatar based on their centauri points.
/// The stops are defined as the number of challenges completed.
const _challengesStops = [
  // sqrt(10) ~= 3, which is the approximate step between each stop
  0,
  10, // ~ 3 days of daily challenge
  30,
  100,
  300, // ~ 3 months of daily challenge
  1000,
  3000, // ~ 3 years of daily challenge
  10000,
];

/// Color used when the user's centauri points are null.
const loadingUserAvatarColor = Colors.transparent;

/// Converts some amount of [centauriPoints] to a color, based on a uniform
/// [LinearSegmentedHSVColormap] (defined by _challengesStop). [brightness]
/// defines the value and saturation of the colormap.
/// If [centauriPoints] is null, the color is transparent.
Color centauriToUserAvatarColor(int? centauriPoints, Brightness brightness) {
  if (centauriPoints == null) return loadingUserAvatarColor;

  final hsvValue = switch (brightness) {
    Brightness.light => 0.9,
    Brightness.dark => 0.5,
  };
  final hsvSaturation = switch (brightness) {
    Brightness.light => 0.4,
    Brightness.dark => 0.8,
  };

  const chalReward = ChallengeRepositoryService.soloChallengeReward;
  final colorMap = LinearSegmentedHSVColormap.uniform(
    _challengesStops.map((nChallenges) => nChallenges * chalReward).toList(),
    value: hsvValue,
    saturation: hsvSaturation,
  );

  return colorMap(centauriPoints).toColor();
}
