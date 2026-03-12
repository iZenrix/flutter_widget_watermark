import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../core/watermark_config.dart';
import '../core/watermark_item.dart';
import '../core/watermark_layout.dart';
import '../utils/alignment_utils.dart';
import '../utils/image_utils.dart';

class RenderedWatermarkItem {
  final WatermarkItem item;
  final Uint8List bytes;

  const RenderedWatermarkItem({
    required this.item,
    required this.bytes,
  });
}

class WatermarkComposer {
  const WatermarkComposer();

  Future<ui.Image> composeSingle({
    required Uint8List sourceBytes,
    required Uint8List watermarkBytes,
    required WatermarkConfig config,
  }) async {
    final ui.Image source = await decodeUiImage(sourceBytes);
    final ui.Image watermark = await decodeUiImage(watermarkBytes);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint sourcePaint = Paint();
    final Paint watermarkPaint = Paint()
      ..filterQuality = FilterQuality.high
      ..color = const Color(0xffffffff).withValues(alpha: config.opacity.clamp(0, 1));

    canvas.drawImage(source, Offset.zero, sourcePaint);

    final Size sourceSize = Size(source.width.toDouble(), source.height.toDouble());
    final Size watermarkSize = Size(
      watermark.width * config.scale,
      watermark.height * config.scale,
    );

    final Offset offset = resolveAlignedOffset(
      canvasSize: sourceSize,
      childSize: watermarkSize,
      alignment: config.alignment,
      padding: config.padding,
    );

    _drawImageTransformed(
      canvas: canvas,
      image: watermark,
      topLeft: offset,
      size: watermarkSize,
      rotation: config.rotation,
      paint: watermarkPaint,
    );

    return recorder.endRecording().toImage(source.width, source.height);
  }

  Future<ui.Image> composeTiled({
    required Uint8List sourceBytes,
    required Uint8List watermarkBytes,
    required WatermarkConfig config,
  }) async {
    final ui.Image source = await decodeUiImage(sourceBytes);
    final ui.Image watermark = await decodeUiImage(watermarkBytes);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint sourcePaint = Paint();
    final Paint watermarkPaint = Paint()
      ..filterQuality = FilterQuality.high
      ..color = const Color(0xffffffff).withValues(alpha: config.opacity.clamp(0, 1));

    canvas.drawImage(source, Offset.zero, sourcePaint);

    final double wmWidth = watermark.width * config.scale;
    final double wmHeight = watermark.height * config.scale;
    final double stepX = wmWidth + config.spacing.width;
    final double stepY = wmHeight + config.spacing.height;

    final int rows = ((source.height + stepY * 4) / stepY).ceil();
    final int cols = ((source.width + stepX * 4) / stepX).ceil();

    for (int row = -2; row < rows; row++) {
      final double y = row * stepY;
      final double rowOffset = config.stagger && row.isOdd ? stepX / 2 : 0;
      for (int col = -2; col < cols; col++) {
        final double x = col * stepX + rowOffset;
        _drawImageTransformed(
          canvas: canvas,
          image: watermark,
          topLeft: Offset(x, y),
          size: Size(wmWidth, wmHeight),
          rotation: config.rotation,
          paint: watermarkPaint,
        );
      }
    }

    return recorder.endRecording().toImage(source.width, source.height);
  }

  Future<ui.Image> composeMulti({
    required Uint8List sourceBytes,
    required List<RenderedWatermarkItem> watermarks,
  }) async {
    final ui.Image source = await decodeUiImage(sourceBytes);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    canvas.drawImage(source, Offset.zero, Paint());

    final Size canvasSize = Size(source.width.toDouble(), source.height.toDouble());

    for (final RenderedWatermarkItem item in watermarks) {
      final ui.Image watermark = await decodeUiImage(item.bytes);
      final Size imageSize = Size(
        watermark.width * item.item.scale,
        watermark.height * item.item.scale,
      );
      final Paint paint = Paint()
        ..filterQuality = FilterQuality.high
        ..color = const Color(0xffffffff).withValues(alpha: item.item.opacity.clamp(0, 1));

      final WatermarkLayout layout = item.item.layout;

      switch (layout.type) {
        case WatermarkLayoutType.aligned:
          final Offset offset = resolveAlignedOffset(
            canvasSize: canvasSize,
            childSize: imageSize,
            alignment: layout.alignment ?? Alignment.center,
            padding: layout.padding,
          );
          _drawImageTransformed(
            canvas: canvas,
            image: watermark,
            topLeft: offset,
            size: imageSize,
            rotation: item.item.rotation,
            paint: paint,
          );
          break;
        case WatermarkLayoutType.offset:
          if (layout.positions != null && layout.positions!.isNotEmpty) {
            for (final position in layout.positions!) {
              _drawImageTransformed(
                canvas: canvas,
                image: watermark,
                topLeft: position.toOffset(),
                size: imageSize,
                rotation: item.item.rotation,
                paint: paint,
              );
            }
          } else {
            _drawImageTransformed(
              canvas: canvas,
              image: watermark,
              topLeft: layout.offset ?? Offset.zero,
              size: imageSize,
              rotation: item.item.rotation,
              paint: paint,
            );
          }
          break;
        case WatermarkLayoutType.tiled:
        case WatermarkLayoutType.diagonal:
          final double stepX = imageSize.width + layout.spacing.width;
          final double stepY = imageSize.height + layout.spacing.height;
          final int rows = ((canvasSize.height + stepY * 4) / stepY).ceil();
          final int cols = ((canvasSize.width + stepX * 4) / stepX).ceil();
          final bool stagger = layout.type == WatermarkLayoutType.diagonal;
          final double rotation = layout.type == WatermarkLayoutType.diagonal
              ? (item.item.rotation == 0 ? -0.55 : item.item.rotation)
              : item.item.rotation;

          for (int row = -2; row < rows; row++) {
            final double y = row * stepY;
            final double rowOffset = stagger && row.isOdd ? stepX / 2 : 0;
            for (int col = -2; col < cols; col++) {
              final double x = col * stepX + rowOffset;
              _drawImageTransformed(
                canvas: canvas,
                image: watermark,
                topLeft: Offset(x, y),
                size: imageSize,
                rotation: rotation,
                paint: paint,
              );
            }
          }
          break;
      }
    }

    return recorder.endRecording().toImage(source.width, source.height);
  }

  void _drawImageTransformed({
    required Canvas canvas,
    required ui.Image image,
    required Offset topLeft,
    required Size size,
    required double rotation,
    required Paint paint,
  }) {
    final Rect src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final Rect dst = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.save();
    canvas.translate(topLeft.dx + size.width / 2, topLeft.dy + size.height / 2);
    if (rotation != 0) {
      canvas.rotate(rotation);
    }
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawImageRect(image, src, dst, paint);
    canvas.restore();
  }
}

Future<ui.Image> composeMultiWatermark({
  required Uint8List sourceBytes,
  required List<WatermarkItem> items,
  required Future<Uint8List> Function(WatermarkItem item) renderItem,
}) async {
  final List<RenderedWatermarkItem> rendered = <RenderedWatermarkItem>[];
  for (final WatermarkItem item in items) {
    rendered.add(
      RenderedWatermarkItem(
        item: item,
        bytes: await renderItem(item),
      ),
    );
  }

  return const WatermarkComposer().composeMulti(
    sourceBytes: sourceBytes,
    watermarks: rendered,
  );
}
