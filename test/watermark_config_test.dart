import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_watermark/flutter_widget_watermark.dart';

void main() {
  group('WatermarkConfig factories', () {
    test('single provides expected defaults', () {
      final WatermarkConfig config = WatermarkConfig.single();

      expect(config.mode, WatermarkMode.single);
      expect(config.alignment, Alignment.bottomRight);
      expect(config.opacity, 0.4);
      expect(config.padding, const EdgeInsets.all(12));
      expect(config.rotation, 0);
      expect(config.scale, 1.0);
    });

    test('tiled provides expected defaults', () {
      final WatermarkConfig config = WatermarkConfig.tiled();

      expect(config.mode, WatermarkMode.tiled);
      expect(config.opacity, 0.15);
      expect(config.rotation, -0.4);
      expect(config.spacing, const Size(80, 80));
      expect(config.stagger, false);
    });

    test('diagonal provides expected defaults', () {
      final WatermarkConfig config = WatermarkConfig.diagonal();

      expect(config.mode, WatermarkMode.diagonal);
      expect(config.opacity, 0.18);
      expect(config.rotation, -0.55);
      expect(config.spacing, const Size(100, 100));
      expect(config.stagger, true);
    });

    test('custom stores manual positions', () {
      const List<WatermarkPosition> positions = <WatermarkPosition>[
        WatermarkPosition(12, 34),
        WatermarkPosition(56, 78),
      ];

      final WatermarkConfig config = WatermarkConfig.custom(
        positions: positions,
        opacity: 0.7,
      );

      expect(config.mode, WatermarkMode.custom);
      expect(config.positions, positions);
      expect(config.opacity, 0.7);
    });
  });

  group('WatermarkLayout factories', () {
    test('aligned layout keeps alignment and padding', () {
      final WatermarkLayout layout = WatermarkLayout.aligned(
        Alignment.topRight,
        padding: const EdgeInsets.all(10),
      );

      expect(layout.type, WatermarkLayoutType.aligned);
      expect(layout.alignment, Alignment.topRight);
      expect(layout.padding, const EdgeInsets.all(10));
    });

    test('diagonal layout stores spacing', () {
      final WatermarkLayout layout = WatermarkLayout.diagonal(
        spacing: const Size(20, 24),
      );

      expect(layout.type, WatermarkLayoutType.diagonal);
      expect(layout.spacing, const Size(20, 24));
    });
  });

  group('WidgetWatermark API naming', () {
    test('legacy API class still exists for compatibility', () {
      expect(FlutterWidgetWatermark, isNotNull);
      expect(WidgetWatermark, isNotNull);
    });
  });
}
