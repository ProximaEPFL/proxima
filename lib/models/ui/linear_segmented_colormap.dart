import "dart:ui";

import "package:collection/collection.dart";

class LinearSegmentedColormap {
  late final List<int> stops;
  late final List<Color> colors;

  LinearSegmentedColormap(Map<int, Color> colorsStops) {
    final unsortedEntries = colorsStops.entries;
    final sortedEntries = unsortedEntries.sorted(
      // We sort by stop value (the key of the map)
      (a, b) => a.key.compareTo(b.key),
    );

    // Stops are distinct since we use a map
    stops = sortedEntries.map((entry) => entry.key).toList();
    colors = sortedEntries.map((entry) => entry.value).toList();

    assert(stops.isNotEmpty, "There must be at least one color stop");
  }

  Color call(int value) {
    final indices = List.generate(stops.length, (index) => index);
    final lowerBoundIdx = indices.lastWhereOrNull(
      (index) => stops[index] <= value,
    );
    if (lowerBoundIdx == null) {
      // value is less than the first stop
      return colors.first;
    }
    if (lowerBoundIdx == stops.length - 1) {
      // value is greater than or equal to the last stop
      return colors.last;
    }

    final upperBoundIdx = lowerBoundIdx + 1;

    // The percentage at which value is in the range from stops[lowerBound] to stops[upperBound]
    final interpolationFactor = (value - stops[lowerBoundIdx]) /
        (stops[upperBoundIdx] - stops[lowerBoundIdx]);

    return Color.lerp(
      colors[lowerBoundIdx],
      colors[upperBoundIdx],
      interpolationFactor,
    )!;
  }
}
