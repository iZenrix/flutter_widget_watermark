import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'composer/watermark_composer.dart';
import 'core/image_output_format.dart';
import 'core/watermark_config.dart';
import 'core/watermark_item.dart';
import 'core/watermark_layout.dart';
import 'core/watermark_position.dart';
import 'renderer/widget_to_image_renderer.dart';
import 'utils/image_utils.dart';

/// Main entry point for rendering Flutter widgets into image watermarks.
///
/// Prefer [WidgetWatermark] for new code. [FlutterWidgetWatermark] remains as a
/// backwards-compatible alias.
class WidgetWatermark {
  WidgetWatermark._();

  static const WidgetToImageRenderer _renderer = WidgetToImageRenderer();
  static const WatermarkComposer _composer = WatermarkComposer();

  static Future<Uint8List> applyToFile({
    required BuildContext context,
    required File file,
    required Widget watermark,
    required Size watermarkSize,
    WatermarkConfig config = const WatermarkConfig(mode: WatermarkMode.single),
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
  }) async {
    final Uint8List imageBytes = await file.readAsBytes();

    return applyToBytes(
      context: context,
      imageBytes: imageBytes,
      watermark: watermark,
      watermarkSize: watermarkSize,
      config: config,
      pixelRatio: pixelRatio,
      format: format,
      jpegQuality: jpegQuality,
    );
  }

  static Future<Uint8List> applyToPath({
    required BuildContext context,
    required String imagePath,
    required Widget watermark,
    required Size watermarkSize,
    WatermarkConfig config = const WatermarkConfig(mode: WatermarkMode.single),
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
  }) {
    return applyToFile(
      context: context,
      file: File(imagePath),
      watermark: watermark,
      watermarkSize: watermarkSize,
      config: config,
      pixelRatio: pixelRatio,
      format: format,
      jpegQuality: jpegQuality,
    );
  }

  static Future<Uint8List> applyToUrl({
    required BuildContext context,
    required String imageUrl,
    required Widget watermark,
    required Size watermarkSize,
    WatermarkConfig config = const WatermarkConfig(mode: WatermarkMode.single),
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
    Map<String, String>? headers,
  }) async {
    final Uint8List imageBytes = await _downloadImageBytes(
      imageUrl,
      headers: headers,
    );

    return applyToBytes(
      context: context,
      imageBytes: imageBytes,
      watermark: watermark,
      watermarkSize: watermarkSize,
      config: config,
      pixelRatio: pixelRatio,
      format: format,
      jpegQuality: jpegQuality,
    );
  }

  static Future<Uint8List> applyToBytes({
    required BuildContext context,
    required Uint8List imageBytes,
    required Widget watermark,
    required Size watermarkSize,
    WatermarkConfig config = const WatermarkConfig(mode: WatermarkMode.single),
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
  }) async {
    final Uint8List watermarkBytes = await _renderer.render(
      context: context,
      child: watermark,
      size: watermarkSize,
      pixelRatio: pixelRatio,
    );

    late final ui.Image output;

    switch (config.mode) {
      case WatermarkMode.single:
        output = await _composer.composeSingle(
          sourceBytes: imageBytes,
          watermarkBytes: watermarkBytes,
          config: config,
        );
        break;
      case WatermarkMode.tiled:
      case WatermarkMode.grid:
      case WatermarkMode.diagonal:
        output = await _composer.composeTiled(
          sourceBytes: imageBytes,
          watermarkBytes: watermarkBytes,
          config: config,
        );
        break;
      case WatermarkMode.custom:
        final List<RenderedWatermarkItem> rendered = <RenderedWatermarkItem>[
          RenderedWatermarkItem(
            bytes: watermarkBytes,
            item: WatermarkItem(
              widget: watermark,
              size: watermarkSize,
              layout: WatermarkLayout.custom(config.positions ?? const <WatermarkPosition>[]),
              opacity: config.opacity,
              rotation: config.rotation,
              scale: config.scale,
            ),
          ),
        ];
        output = await _composer.composeMulti(
          sourceBytes: imageBytes,
          watermarks: rendered,
        );
        break;
      case WatermarkMode.multi:
        throw UnsupportedError('Use applyMultipleToBytes() for WatermarkMode.multi.');
    }

    return encodeUiImage(output, format: format, jpegQuality: jpegQuality);
  }

  static Future<Uint8List> applyMultipleToBytes({
    required BuildContext context,
    required Uint8List imageBytes,
    required List<WatermarkItem> watermarks,
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
  }) async {
    final ui.Image image = await composeMultiWatermark(
      sourceBytes: imageBytes,
      items: watermarks,
      renderItem: (WatermarkItem item) => _renderer.render(
        context: context,
        child: item.widget,
        size: item.size,
        pixelRatio: pixelRatio,
      ),
    );

    return encodeUiImage(image, format: format, jpegQuality: jpegQuality);
  }

  static Future<Uint8List> _downloadImageBytes(
    String imageUrl, {
    Map<String, String>? headers,
  }) async {
    final Uri uri = Uri.parse(imageUrl);
    final http.Response response = await http.get(uri, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Failed to download image from URL. Status: ${response.statusCode}',
        uri: uri,
      );
    }

    return response.bodyBytes;
  }
}

class FlutterWidgetWatermark {
  FlutterWidgetWatermark._();

  @Deprecated('Use WidgetWatermark.applyToFile instead.')
  static Future<Uint8List> applyFromFile({
    required BuildContext context,
    required File file,
    required Widget watermark,
    required Size watermarkSize,
    WatermarkConfig config = const WatermarkConfig(mode: WatermarkMode.single),
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
  }) {
    return WidgetWatermark.applyToFile(
      context: context,
      file: file,
      watermark: watermark,
      watermarkSize: watermarkSize,
      config: config,
      pixelRatio: pixelRatio,
      format: format,
      jpegQuality: jpegQuality,
    );
  }

  @Deprecated('Use WidgetWatermark.applyToPath instead.')
  static Future<Uint8List> applyFromPath({
    required BuildContext context,
    required String imagePath,
    required Widget watermark,
    required Size watermarkSize,
    WatermarkConfig config = const WatermarkConfig(mode: WatermarkMode.single),
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
  }) {
    return WidgetWatermark.applyToPath(
      context: context,
      imagePath: imagePath,
      watermark: watermark,
      watermarkSize: watermarkSize,
      config: config,
      pixelRatio: pixelRatio,
      format: format,
      jpegQuality: jpegQuality,
    );
  }

  @Deprecated('Use WidgetWatermark.applyToUrl instead.')
  static Future<Uint8List> applyFromUrl({
    required BuildContext context,
    required String imageUrl,
    required Widget watermark,
    required Size watermarkSize,
    WatermarkConfig config = const WatermarkConfig(mode: WatermarkMode.single),
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
    Map<String, String>? headers,
  }) {
    return WidgetWatermark.applyToUrl(
      context: context,
      imageUrl: imageUrl,
      watermark: watermark,
      watermarkSize: watermarkSize,
      config: config,
      pixelRatio: pixelRatio,
      format: format,
      jpegQuality: jpegQuality,
      headers: headers,
    );
  }

  @Deprecated('Use WidgetWatermark.applyToBytes instead.')
  static Future<Uint8List> apply({
    required BuildContext context,
    required Uint8List imageBytes,
    required Widget watermark,
    required Size watermarkSize,
    WatermarkConfig config = const WatermarkConfig(mode: WatermarkMode.single),
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
  }) {
    return WidgetWatermark.applyToBytes(
      context: context,
      imageBytes: imageBytes,
      watermark: watermark,
      watermarkSize: watermarkSize,
      config: config,
      pixelRatio: pixelRatio,
      format: format,
      jpegQuality: jpegQuality,
    );
  }

  @Deprecated('Use WidgetWatermark.applyMultipleToBytes instead.')
  static Future<Uint8List> applyMulti({
    required BuildContext context,
    required Uint8List imageBytes,
    required List<WatermarkItem> watermarks,
    double pixelRatio = 3.0,
    ImageOutputFormat format = ImageOutputFormat.png,
    int jpegQuality = 95,
  }) {
    return WidgetWatermark.applyMultipleToBytes(
      context: context,
      imageBytes: imageBytes,
      watermarks: watermarks,
      pixelRatio: pixelRatio,
      format: format,
      jpegQuality: jpegQuality,
    );
  }
}
