# flutter_widget_watermark

Render any bounded Flutter widget into an image watermark, then merge it into a source image.

This package is useful when your watermark is more than plain text, such as:

- text with custom styles
- icons and logos
- badges, chips, and cards
- any widget tree with a fixed size

## Features

- Single watermark placement
- Repeated tiled watermark placement
- Diagonal repeated watermark placement
- Multiple watermark items in a single export
- PNG and JPEG output
- Source image from bytes, file, path, or URL
- Preview widget for fast UI iteration

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  flutter_widget_watermark:
    git:
      url: https://github.com/iZenrix/flutter_widget_watermark.git
      ref: main
```

Then run:

```bash
flutter pub get
```

## Platform support

Designed for Flutter mobile first.

- Android: supported
- iOS: supported
- Web: limited, because `dart:io` helpers are not available and network/image rendering constraints can differ
- Desktop: should work for many cases, but mobile is the primary target

## Important rendering note

`WidgetWatermark.applyToBytes()` and related methods require a `BuildContext`.
That is because the watermark widget is rendered offscreen using an `OverlayEntry` and `RepaintBoundary` before it is merged into the image.

Your watermark widget must have a clear size through:

- `watermarkSize` when using the single-watermark APIs
- `WatermarkItem.size` when using the multi-watermark API

## Quick start

```dart
final result = await WidgetWatermark.applyToBytes(
  context: context,
  imageBytes: bytes,
  watermarkSize: const Size(220, 60),
  watermark: Container(
    alignment: Alignment.center,
    child: const Text('CONFIDENTIAL'),
  ),
  config: WatermarkConfig.single(
    alignment: Alignment.bottomRight,
    opacity: 0.6,
    padding: const EdgeInsets.all(16),
  ),
);
```

## API naming

### Preferred API for new code

- `WidgetWatermark.applyToBytes()`
- `WidgetWatermark.applyToFile()`
- `WidgetWatermark.applyToPath()`
- `WidgetWatermark.applyToUrl()`
- `WidgetWatermark.applyMultipleToBytes()`

### Backward-compatible API

The old class and method names are still available:

- `FlutterWidgetWatermark.apply()`
- `FlutterWidgetWatermark.applyFromFile()`
- `FlutterWidgetWatermark.applyFromPath()`
- `FlutterWidgetWatermark.applyFromUrl()`
- `FlutterWidgetWatermark.applyMulti()`

Those legacy methods now forward to the new API and are marked deprecated.

## Source image examples

### From bytes

```dart
final result = await WidgetWatermark.applyToBytes(
  context: context,
  imageBytes: bytes,
  watermarkSize: const Size(220, 60),
  watermark: const Center(child: Text('CONFIDENTIAL')),
  config: WatermarkConfig.single(
    alignment: Alignment.bottomRight,
    opacity: 0.5,
    padding: const EdgeInsets.all(16),
  ),
);
```

### From URL

```dart
final result = await WidgetWatermark.applyToUrl(
  context: context,
  imageUrl: 'https://picsum.photos/1200/800',
  watermarkSize: const Size(220, 60),
  watermark: const Center(child: Text('CONFIDENTIAL')),
  config: WatermarkConfig.diagonal(
    opacity: 0.12,
    spacing: const Size(48, 56),
  ),
);
```

For private URLs:

```dart
final result = await WidgetWatermark.applyToUrl(
  context: context,
  imageUrl: 'https://example.com/private-image.jpg',
  headers: {
    'Authorization': 'Bearer your-token',
  },
  watermarkSize: const Size(220, 60),
  watermark: const Center(child: Text('PRIVATE')),
);
```

### From file path

```dart
final result = await WidgetWatermark.applyToPath(
  context: context,
  imagePath: file.path,
  watermarkSize: const Size(180, 50),
  watermark: const Center(child: Text('LOCAL FILE')),
);
```

## Repeated watermark example

```dart
final result = await WidgetWatermark.applyToBytes(
  context: context,
  imageBytes: bytes,
  watermarkSize: const Size(180, 46),
  watermark: const Center(
    child: Text(
      'PROOF',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    ),
  ),
  config: WatermarkConfig.diagonal(
    opacity: 0.14,
    rotation: -0.8,
    spacing: const Size(24, 30),
  ),
);
```

## Multiple watermarks example

```dart
final result = await WidgetWatermark.applyMultipleToBytes(
  context: context,
  imageBytes: bytes,
  watermarks: [
    WatermarkItem(
      widget: const Center(child: Text('TOP LEFT')),
      size: const Size(120, 40),
      layout: WatermarkLayout.aligned(
        Alignment.topLeft,
        padding: const EdgeInsets.all(16),
      ),
      opacity: 0.8,
    ),
    WatermarkItem(
      widget: const Center(child: Text('CONFIDENTIAL')),
      size: const Size(200, 50),
      layout: WatermarkLayout.diagonal(
        spacing: const Size(90, 90),
      ),
      opacity: 0.1,
      rotation: -0.55,
    ),
  ],
);
```

## Preview without exporting

Use `WatermarkPreview` while designing your UI:

```dart
WatermarkPreview(
  imageProvider: MemoryImage(bytes),
  watermark: const Center(child: Text('CONFIDENTIAL')),
  watermarkSize: const Size(220, 60),
  config: WatermarkConfig.diagonal(
    opacity: 0.12,
    spacing: const Size(48, 56),
  ),
)
```

## Watermark modes

### `WatermarkConfig.single()`
Places exactly one watermark using `alignment` and `padding`.

### `WatermarkConfig.tiled()`
Repeats the watermark across the image using `spacing` and optional `stagger`.

### `WatermarkConfig.grid()`
Repeats the watermark in a more regular grid pattern.

### `WatermarkConfig.diagonal()`
Repeats the watermark diagonally. Useful for proof, confidential, or anti-crop overlays.

### `WatermarkConfig.custom()`
Places the watermark at manually provided coordinates.

## Limitations

- The watermark widget should be bounded to a known size.
- Large source images can use significant memory during decoding and encoding.
- URL helpers use `http`, while file helpers rely on `dart:io`.
- Web support is not the main target for this package version.

## Testing

This package includes tests for:

- config factory defaults
- layout factory defaults
- alignment offset calculation

Image rendering tests are intentionally light here because widget-to-image rendering can be sensitive to environment and frame timing.

## Example app

See the included `example/` app for:

- bytes input
- URL input
- path input
- preview mode
- multi-watermark mode
