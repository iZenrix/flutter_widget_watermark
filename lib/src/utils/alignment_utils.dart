import 'package:flutter/widgets.dart';

Offset resolveAlignedOffset({
  required Size canvasSize,
  required Size childSize,
  required Alignment alignment,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  final double x = switch (alignment.x) {
    <= -0.99 => padding.left,
    >= 0.99 => canvasSize.width - childSize.width - padding.right,
    _ => (canvasSize.width - childSize.width) / 2 + (alignment.x * (canvasSize.width - childSize.width) / 2),
  };

  final double y = switch (alignment.y) {
    <= -0.99 => padding.top,
    >= 0.99 => canvasSize.height - childSize.height - padding.bottom,
    _ => (canvasSize.height - childSize.height) / 2 + (alignment.y * (canvasSize.height - childSize.height) / 2),
  };

  return Offset(x.clamp(0, canvasSize.width - childSize.width), y.clamp(0, canvasSize.height - childSize.height));
}
