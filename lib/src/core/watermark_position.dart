import 'package:flutter/widgets.dart';

class WatermarkPosition {
  final double x;
  final double y;

  const WatermarkPosition(this.x, this.y);

  Offset toOffset() => Offset(x, y);
}
