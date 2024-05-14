import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:flutter/painting.dart";

@immutable
class LinearSegmentedHSVColormap {
  late final List<int> stops;
  late final List<HSVColor> colors;

  LinearSegmentedHSVColormap(Map<int, HSVColor> colorsStops) {
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

  factory LinearSegmentedHSVColormap.uniform(
    List<int> stops, {
    double hueStart = 0,
    double hueEnd = 330,
    double saturation = 0.8,
    double value = 0.5,
  }) {
    assert(stops.length >= 2, "There must be at least two color stops");
    final colors = stops.mapIndexed((i, _) {
      final hue = hueStart + (hueEnd - hueStart) * i / (stops.length - 1);
      return HSVColor.fromAHSV(1, hue, saturation, value);
    });

    final colorStops = Map.fromIterables(stops, colors);
    return LinearSegmentedHSVColormap(colorStops);
  }

  HSVColor call(int value) {
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

    return HSVColor.lerp(
      colors[lowerBoundIdx],
      colors[upperBoundIdx],
      interpolationFactor,
    )!;
  }
}
