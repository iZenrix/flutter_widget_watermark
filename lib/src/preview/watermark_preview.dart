import 'package:flutter/widgets.dart';

import '../core/watermark_config.dart';
import '../core/watermark_item.dart';
import '../core/watermark_layout.dart';

class WatermarkPreview extends StatelessWidget {

  const WatermarkPreview({
    super.key,
    required this.imageProvider,
    this.watermark,
    this.config,
    this.watermarks,
    this.watermarkSize,
  });
  final ImageProvider imageProvider;
  final Widget? watermark;
  final WatermarkConfig? config;
  final List<WatermarkItem>? watermarks;
  final Size? watermarkSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image(image: imageProvider, fit: BoxFit.contain),
            if (watermark != null && config != null && watermarkSize != null)
              ..._buildSinglePreview(constraints),
            if (watermarks != null && watermarks!.isNotEmpty)
              ...watermarks!.expand((e) => _buildItemPreview(e, constraints)),
          ],
        );
      },
    );
  }

  List<Widget> _buildSinglePreview(BoxConstraints constraints) {
    final WatermarkConfig cfg = config!;
    switch (cfg.mode) {
      case WatermarkMode.single:
        return [
          Align(
            alignment: cfg.alignment,
            child: Padding(
              padding: cfg.padding,
              child: Opacity(
                opacity: cfg.opacity,
                child: Transform.rotate(
                  angle: cfg.rotation,
                  child: Transform.scale(
                    scale: cfg.scale,
                    child: SizedBox(
                      width: watermarkSize!.width,
                      height: watermarkSize!.height,
                      child: watermark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      case WatermarkMode.tiled:
      case WatermarkMode.grid:
      case WatermarkMode.diagonal:
        return _buildTiledWidgets(
          child: watermark!,
          containerSize: constraints.biggest,
          watermarkSize: watermarkSize!,
          opacity: cfg.opacity,
          rotation: cfg.rotation,
          spacing: cfg.spacing,
          stagger: cfg.stagger || cfg.mode == WatermarkMode.diagonal,
          scale: cfg.scale,
        );
      case WatermarkMode.custom:
        return (cfg.positions ?? const [])
            .map(
              (p) => Positioned(
                left: p.x,
                top: p.y,
                child: Opacity(
                  opacity: cfg.opacity,
                  child: Transform.rotate(
                    angle: cfg.rotation,
                    child: Transform.scale(
                      scale: cfg.scale,
                      child: SizedBox(
                        width: watermarkSize!.width,
                        height: watermarkSize!.height,
                        child: watermark,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList();
      case WatermarkMode.multi:
        return const [];
    }
  }

  List<Widget> _buildItemPreview(WatermarkItem item, BoxConstraints constraints) {
    switch (item.layout.type) {
      case WatermarkLayoutType.aligned:
        return [
          Align(
            alignment: item.layout.alignment ?? Alignment.center,
            child: Padding(
              padding: item.layout.padding,
              child: Opacity(
                opacity: item.opacity,
                child: Transform.rotate(
                  angle: item.rotation,
                  child: Transform.scale(
                    scale: item.scale,
                    child: SizedBox(
                      width: item.size.width,
                      height: item.size.height,
                      child: item.widget,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      case WatermarkLayoutType.offset:
        if (item.layout.positions != null && item.layout.positions!.isNotEmpty) {
          return item.layout.positions!
              .map(
                (p) => Positioned(
                  left: p.x,
                  top: p.y,
                  child: Opacity(
                    opacity: item.opacity,
                    child: Transform.rotate(
                      angle: item.rotation,
                      child: Transform.scale(
                        scale: item.scale,
                        child: SizedBox(
                          width: item.size.width,
                          height: item.size.height,
                          child: item.widget,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList();
        }
        return [
          Positioned(
            left: item.layout.offset?.dx ?? 0,
            top: item.layout.offset?.dy ?? 0,
            child: Opacity(
              opacity: item.opacity,
              child: Transform.rotate(
                angle: item.rotation,
                child: Transform.scale(
                  scale: item.scale,
                  child: SizedBox(
                    width: item.size.width,
                    height: item.size.height,
                    child: item.widget,
                  ),
                ),
              ),
            ),
          ),
        ];
      case WatermarkLayoutType.tiled:
      case WatermarkLayoutType.diagonal:
        return _buildTiledWidgets(
          child: item.widget,
          containerSize: constraints.biggest,
          watermarkSize: item.size,
          opacity: item.opacity,
          rotation: item.layout.type == WatermarkLayoutType.diagonal && item.rotation == 0 ? -0.55 : item.rotation,
          spacing: item.layout.spacing,
          stagger: item.layout.type == WatermarkLayoutType.diagonal,
          scale: item.scale,
        );
    }
  }

  List<Widget> _buildTiledWidgets({
    required Widget child,
    required Size containerSize,
    required Size watermarkSize,
    required double opacity,
    required double rotation,
    required Size spacing,
    required bool stagger,
    required double scale,
  }) {
    final double width = watermarkSize.width * scale;
    final double height = watermarkSize.height * scale;
    final double stepX = width + spacing.width;
    final double stepY = height + spacing.height;

    final int rows = ((containerSize.height + stepY * 4) / stepY).ceil();
    final int cols = ((containerSize.width + stepX * 4) / stepX).ceil();

    final List<Widget> widgets = [];

    for (int row = -2; row < rows; row++) {
      final double y = row * stepY;
      final double rowOffset = stagger && row.isOdd ? stepX / 2 : 0;

      for (int col = -2; col < cols; col++) {
        final double x = col * stepX + rowOffset;
        widgets.add(
          Positioned(
            left: x,
            top: y,
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: rotation,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: child,
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
