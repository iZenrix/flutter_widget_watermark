import 'package:flutter/widgets.dart';

class WatermarkPosition {

  const WatermarkPosition(this.x, this.y);
  final double x;
  final double y;

  Offset toOffset() => Offset(x, y);
}
