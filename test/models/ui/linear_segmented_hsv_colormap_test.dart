import "package:collection/collection.dart";
import "package:flutter/painting.dart";
import "package:flutter_test/flutter_test.dart";
import "package:proxima/models/ui/linear_segmented_hsv_colormap.dart";

void main() {
  group("Linear segmented hsv colormap with default constructor", () {
    late List<int> stops;
    late List<HSVColor> colors;
    late LinearSegmentedHSVColormap colormap;

    setUp(() {
      stops = List.generate(10, (i) => i * (i - 4.5))
          .map((x) => x.toInt())
          .toList();

      colors = List.generate(
        10,
        (i) {
          final factor = 1.0 / (i + 1);
          return HSVColor.fromAHSV(
            1.0 * factor,
            0.5 * factor,
            0.3 * factor,
            0.25 * factor,
          );
        },
      );

      colormap = LinearSegmentedHSVColormap(
        Map.fromIterables(stops, colors),
      );
    });

    test("Gives the correct value at stops", () {
      for (int i = 0; i < stops.length; ++i) {
        expect(colormap(stops[i]), equals(colors[i]));
      }
    });

    test("Gives the correct value below the smallest stop", () {
      final smallestStopIndex = stops.indexOf(stops.min);
      final smallestStop = stops[smallestStopIndex];
      final smallestStopColor = colors[smallestStopIndex];

      for (int i = 1; i < 100; ++i) {
        expect(colormap(smallestStop - i), equals(smallestStopColor));
      }
    });

    test("Gives the correct value above the largest stop", () {
      final largestStopIndex = stops.indexOf(stops.max);
      final largestStop = stops[largestStopIndex];
      final largestStopColor = colors[largestStopIndex];

      for (int i = 1; i < 100; ++i) {
        expect(colormap(largestStop + i), equals(largestStopColor));
      }
    });

    test("Gives the correct value between stops", () {
      final max = stops.max;
      final secondMax = stops.where((x) => x < max).max;

      final maxIndex = stops.indexOf(max);
      final secondMaxIndex = stops.indexOf(secondMax);
      final maxColor = colors[maxIndex];
      final secondMaxColor = colors[secondMaxIndex];

      final otherIndex = secondMax + 1;
      final interpolationFactor = 1 / (max - secondMax);
      final otherColor = HSVColor.lerp(
        secondMaxColor,
        maxColor,
        interpolationFactor,
      );

      expect(colormap(otherIndex), equals(otherColor));
    });
  });

  group("Uniform linear segmented hsv colormap", () {
    const double minHue = 17;
    const double maxHue = 229;
    const double saturation = 0.3141592;
    const double value = 0.2718281;

    late List<int> stops;
    late LinearSegmentedHSVColormap colormap;

    setUp(() {
      stops = List.generate(5, (i) => i * 10).toList();

      colormap = LinearSegmentedHSVColormap.uniform(
        stops,
        hueStart: minHue,
        hueEnd: maxHue,
        saturation: saturation,
        value: value,
      );
    });

    test("Colors at stop have correct value and saturation", () {
      for (int i = 0; i < stops.length; ++i) {
        final color = colormap(stops[i]);
        expect(color.saturation, equals(saturation));
        expect(color.value, equals(value));
      }
    });

    test("Colors at bounds have correct hue", () {
      expect(colormap(stops.first).hue, equals(minHue));
      expect(colormap(stops.last).hue, equals(maxHue));
    });

    test("Colors between stops have constant hue difference", () {
      final hues = stops.map((stop) => colormap(stop).hue).toList();
      final hueDifferences = List.generate(
        hues.length - 1,
        (i) => hues[i + 1] - hues[i],
      );
      expect(hueDifferences, everyElement(equals(hueDifferences.first)));
    });
  });
}
