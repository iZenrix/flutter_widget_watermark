import 'package:flutter/widgets.dart';

import 'watermark_position.dart';

enum WatermarkLayoutType {
  aligned,
  offset,
  tiled,
  diagonal,
}

class WatermarkLayout {

  const WatermarkLayout._({
    required this.type,
    this.alignment,
    this.offset,
    this.padding = EdgeInsets.zero,
    this.spacing = const Size(60, 60),
    this.positions,
  });

  factory WatermarkLayout.aligned(
    Alignment alignment, {
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return WatermarkLayout._(
      type: WatermarkLayoutType.aligned,
      alignment: alignment,
      padding: padding,
    );
  }

  factory WatermarkLayout.offset(
    Offset offset, {
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return WatermarkLayout._(
      type: WatermarkLayoutType.offset,
      offset: offset,
      padding: padding,
    );
  }

  factory WatermarkLayout.tiled({
    Size spacing = const Size(60, 60),
  }) {
    return WatermarkLayout._(
      type: WatermarkLayoutType.tiled,
      spacing: spacing,
    );
  }

  factory WatermarkLayout.diagonal({
    Size spacing = const Size(80, 80),
  }) {
    return WatermarkLayout._(
      type: WatermarkLayoutType.diagonal,
      spacing: spacing,
    );
  }

  factory WatermarkLayout.custom(List<WatermarkPosition> positions) {
    return WatermarkLayout._(
      type: WatermarkLayoutType.offset,
      positions: positions,
    );
  }
  final WatermarkLayoutType type;
  final Alignment? alignment;
  final Offset? offset;
  final EdgeInsets padding;
  final Size spacing;
  final List<WatermarkPosition>? positions;
}
