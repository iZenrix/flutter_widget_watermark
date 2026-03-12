import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetToImageRenderer {
  const WidgetToImageRenderer();

  Future<Uint8List> render({
    required BuildContext context,
    required Widget child,
    required Size size,
    double pixelRatio = 3.0,
    Duration delay = const Duration(milliseconds: 24),
  }) async {
    final GlobalKey repaintKey = GlobalKey();
    final Completer<Uint8List> completer = Completer<Uint8List>();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return Positioned(
          left: -10000,
          top: -10000,
          child: IgnorePointer(
            child: Material(
              type: MaterialType.transparency,
              child: RepaintBoundary(
                key: repaintKey,
                child: Directionality(
                  textDirection: Directionality.of(context),
                  child: MediaQuery(
                    data: MediaQuery.of(context),
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      throw FlutterError('No Overlay found. Wrap your app with MaterialApp/CupertinoApp/Navigator.');
    }

    overlay.insert(entry);

    try {
      await Future<void>.delayed(delay);
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final RenderRepaintBoundary? boundary =
          repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw StateError('Failed to find watermark repaint boundary.');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to convert widget watermark image to bytes.');
      }

      completer.complete(byteData.buffer.asUint8List());
    } catch (e, st) {
      completer.completeError(e, st);
    } finally {
      entry.remove();
    }

    return completer.future;
  }
}
