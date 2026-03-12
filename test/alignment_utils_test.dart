import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_watermark/src/utils/alignment_utils.dart';

void main() {
  group('resolveAlignedOffset', () {
    const Size canvasSize = Size(300, 200);
    const Size childSize = Size(50, 20);

    test('places item at top left with padding', () {
      final Offset offset = resolveAlignedOffset(
        canvasSize: canvasSize,
        childSize: childSize,
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.only(left: 10, top: 12),
      );

      expect(offset.dx, 10);
      expect(offset.dy, 12);
    });

    test('places item at center', () {
      final Offset offset = resolveAlignedOffset(
        canvasSize: canvasSize,
        childSize: childSize,
        alignment: Alignment.center,
      );

      expect(offset.dx, 125);
      expect(offset.dy, 90);
    });

    test('places item at bottom right with padding', () {
      final Offset offset = resolveAlignedOffset(
        canvasSize: canvasSize,
        childSize: childSize,
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.only(right: 8, bottom: 6),
      );

      expect(offset.dx, 242);
      expect(offset.dy, 174);
    });
  });
}
