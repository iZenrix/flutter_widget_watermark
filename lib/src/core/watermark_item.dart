import 'package:flutter/widgets.dart';

import 'watermark_layout.dart';

class WatermarkItem {

  const WatermarkItem({
    required this.widget,
    required this.size,
    required this.layout,
    this.opacity = 1,
    this.rotation = 0,
    this.scale = 1,
  });
  final Widget widget;
  final Size size;
  final WatermarkLayout layout;
  final double opacity;
  final double rotation;
  final double scale;
}
