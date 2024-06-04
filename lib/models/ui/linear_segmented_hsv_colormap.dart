import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:flutter/painting.dart";

/// A linear segmented HSV colormap, just like python's matplotlib.colors.LinearSegmentedColormap.
/// It is given a map of stops and colors, and it can interpolate between them. For instance,
/// if we know have the stop 50 with colour blue and the stop 100 with colour red, asking the value
/// at 75 will yield purple.
/// Any value below all the stops will yield colour of the smallest stop, and any value above all the stops
/// will yield the colour of the largest stop.
@immutable
class LinearSegmentedHSVColormap {
  late final List<int> stops;
  late final List<HSVColor> colors;

  /// Creates a linear segmented HSV colormap.
  /// [colorStops] is a map of stops and colours (the colour that we want
  /// to have at each stop). At other values, the colour is interpolated.
  /// There must be at least one color stop.
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

  /// Creates a linear segmented HSV colormap with a uniform distribution of colors.
  /// [stops] is a list of values that define the stops of the colormap. Their corresponding
  /// colors are interpolated between [hueStart] and [hueEnd] (in degrees), with a fixed
  /// [saturation] and [value]. The distance between each stop colour is constant.
  /// There must be at least two colour stops.
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

  /// Returns the color at the given value. See the class documentation
  /// for more details.
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
