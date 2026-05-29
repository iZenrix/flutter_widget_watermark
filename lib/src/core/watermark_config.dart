import 'package:flutter/widgets.dart';

import 'watermark_position.dart';

enum WatermarkMode {
  single,
  tiled,
  grid,
  multi,
  diagonal,
  custom,
}

class WatermarkConfig {

  const WatermarkConfig({
    required this.mode,
    this.opacity = 1.0,
    this.rotation = 0,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
    this.spacing = const Size(60, 60),
    this.backgroundColor,
    this.fit = BoxFit.contain,
    this.scale = 1.0,
    this.positions,
    this.stagger = false,
  });

  factory WatermarkConfig.single({
    Alignment alignment = Alignment.bottomRight,
    double opacity = 0.4,
    EdgeInsets padding = const EdgeInsets.all(12),
    double rotation = 0,
    double scale = 1.0,
  }) {
    return WatermarkConfig(
      mode: WatermarkMode.single,
      alignment: alignment,
      opacity: opacity,
      padding: padding,
      rotation: rotation,
      scale: scale,
    );
  }

  factory WatermarkConfig.tiled({
    double opacity = 0.15,
    double rotation = -0.4,
    Size spacing = const Size(80, 80),
    double scale = 1.0,
    bool stagger = false,
  }) {
    return WatermarkConfig(
      mode: WatermarkMode.tiled,
      opacity: opacity,
      rotation: rotation,
      spacing: spacing,
      scale: scale,
      stagger: stagger,
    );
  }

  factory WatermarkConfig.grid({
    double opacity = 0.18,
    double rotation = 0,
    Size spacing = const Size(90, 90),
    double scale = 1.0,
  }) {
    return WatermarkConfig(
      mode: WatermarkMode.grid,
      opacity: opacity,
      rotation: rotation,
      spacing: spacing,
      scale: scale,
    );
  }

  factory WatermarkConfig.diagonal({
    double opacity = 0.18,
    double rotation = -0.55,
    Size spacing = const Size(100, 100),
    double scale = 1.0,
    bool stagger = true,
  }) {
    return WatermarkConfig(
      mode: WatermarkMode.diagonal,
      opacity: opacity,
      rotation: rotation,
      spacing: spacing,
      scale: scale,
      stagger: stagger,
    );
  }

  factory WatermarkConfig.custom({
    required List<WatermarkPosition> positions,
    double opacity = 0.4,
    double rotation = 0,
    double scale = 1.0,
  }) {
    return WatermarkConfig(
      mode: WatermarkMode.custom,
      positions: positions,
      opacity: opacity,
      rotation: rotation,
      scale: scale,
    );
  }
  final WatermarkMode mode;
  final double opacity;
  final double rotation;
  final EdgeInsets padding;
  final Alignment alignment;
  final Size spacing;
  final Color? backgroundColor;
  final BoxFit fit;
  final double scale;
  final List<WatermarkPosition>? positions;
  final bool stagger;
}
