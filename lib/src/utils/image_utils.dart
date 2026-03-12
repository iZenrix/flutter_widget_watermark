import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

import '../core/image_output_format.dart';

Future<ui.Image> decodeUiImage(Uint8List bytes) async {
  final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

Future<Uint8List> encodeUiImage(
  ui.Image image, {
  required ImageOutputFormat format,
  int jpegQuality = 95,
}) async {
  final ByteData? pngData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (pngData == null) {
    throw StateError('Failed to encode image to PNG bytes.');
  }

  final Uint8List pngBytes = pngData.buffer.asUint8List();

  if (format == ImageOutputFormat.png) {
    return pngBytes;
  }

  final img.Image? decoded = img.decodeImage(pngBytes);
  if (decoded == null) {
    throw StateError('Failed to decode PNG bytes for JPEG conversion.');
  }

  return Uint8List.fromList(img.encodeJpg(decoded, quality: jpegQuality));
}
