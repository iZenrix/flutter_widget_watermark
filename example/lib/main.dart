import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_watermark/flutter_widget_watermark.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const WatermarkDemoPage(),
    );
  }
}

class WatermarkDemoPage extends StatefulWidget {
  const WatermarkDemoPage({super.key});

  @override
  State<WatermarkDemoPage> createState() => _WatermarkDemoPageState();
}

class _WatermarkDemoPageState extends State<WatermarkDemoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Uint8List? _sourceBytes;
  Uint8List? _resultBytes;
  bool _loading = false;
  String _status = 'Tap one of the buttons below to generate a watermark.';

  static const String _sampleUrl = 'https://picsum.photos/1200/800';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSampleAsset();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSampleAsset() async {
    final ByteData data = await rootBundle.load('assets/sample.png');
    setState(() {
      _sourceBytes = data.buffer.asUint8List();
      _status = 'Loaded example asset from example/assets/sample.png';
    });
  }

  Future<void> _runTask(Future<Uint8List> Function() task, String successText) async {
    setState(() {
      _loading = true;
      _status = 'Processing...';
    });

    try {
      final Uint8List result = await task();
      if (!mounted) return;
      setState(() {
        _resultBytes = result;
        _status = successText;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Failed: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildBadgeWatermark(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({required Uint8List? bytes, required String emptyText}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: bytes == null
            ? Center(child: Text(emptyText, textAlign: TextAlign.center))
            : InteractiveViewer(
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
      ),
    );
  }

  Future<void> _applyFromBytesSingle() async {
    if (_sourceBytes == null) return;

    await _runTask(
      () => WidgetWatermark.applyToBytes(
        context: context,
        imageBytes: _sourceBytes!,
        watermarkSize: const Size(240, 64),
        watermark: _buildBadgeWatermark('Taken by All Mart'),
        config: WatermarkConfig.single(
          alignment: Alignment.bottomRight,
          opacity: 0.92,
          padding: const EdgeInsets.all(16),
        ),
      ),
      'Done: single watermark from in-memory bytes.',
    );
  }

  Future<void> _applyFromUrlDiagonal() async {
    await _runTask(
      () => WidgetWatermark.applyToUrl(
        context: context,
        imageUrl: _sampleUrl,
        watermarkSize: const Size(210, 52),
        watermark: const Center(
          child: Text(
            'CONFIDENTIAL',
            style: TextStyle(
              color: Colors.red,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        config: WatermarkConfig.diagonal(
          opacity: 0.14,
          spacing: const Size(72, 84),
        ),
      ),
      'Done: diagonal repeated watermark from URL.',
    );
  }

  Future<void> _applyFromPathGrid() async {
    final ByteData data = await rootBundle.load('assets/sample.png');
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/watermark_example_source.png');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);

    await _runTask(
      () => WidgetWatermark.applyToPath(
        context: context,
        imagePath: file.path,
        watermarkSize: const Size(180, 48),
        watermark: const Center(
          child: Text(
            'LOCAL FILE',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        config: WatermarkConfig.grid(
          opacity: 0.17,
          spacing: const Size(88, 88),
        ),
      ),
      'Done: grid watermark from a local file path.',
    );
  }

  Future<void> _applyMultiWatermark() async {
    if (_sourceBytes == null) return;

    await _runTask(
      () => WidgetWatermark.applyMultipleToBytes(
        context: context,
        imageBytes: _sourceBytes!,
        watermarks: [
          WatermarkItem(
            widget: _buildBadgeWatermark('Preview / Multi'),
            size: const Size(210, 58),
            layout: WatermarkLayout.aligned(
              Alignment.topLeft,
              padding: const EdgeInsets.all(16),
            ),
            opacity: 0.95,
          ),
          WatermarkItem(
            widget: const Center(
              child: Text(
                'PRIVATE',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            size: const Size(180, 56),
            layout: WatermarkLayout.diagonal(
              spacing: const Size(90, 90),
            ),
            opacity: 0.10,
            rotation: -0.6,
          ),
          WatermarkItem(
            widget: const Center(
              child: Text(
                'bottom-right',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            size: const Size(140, 40),
            layout: WatermarkLayout.aligned(
              Alignment.bottomRight,
              padding: const EdgeInsets.all(16),
            ),
            opacity: 0.9,
          ),
        ],
      ),
      'Done: multi watermark layout.',
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: _loading ? null : _loadSampleAsset,
          icon: const Icon(Icons.image),
          label: const Text('Reload Asset'),
        ),
        OutlinedButton.icon(
          onPressed: _loading ? null : _applyFromBytesSingle,
          icon: const Icon(Icons.filter_1),
          label: const Text('Bytes / Single'),
        ),
        OutlinedButton.icon(
          onPressed: _loading ? null : _applyFromUrlDiagonal,
          icon: const Icon(Icons.link),
          label: const Text('URL / Diagonal'),
        ),
        OutlinedButton.icon(
          onPressed: _loading ? null : _applyFromPathGrid,
          icon: const Icon(Icons.folder_open),
          label: const Text('Path / Grid'),
        ),
        OutlinedButton.icon(
          onPressed: _loading ? null : _applyMultiWatermark,
          icon: const Icon(Icons.layers),
          label: const Text('Multi'),
        ),
      ],
    );
  }

  Widget _buildPreviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview widget',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'This tab shows WatermarkPreview only. It does not export bytes; it previews the layout in the UI.',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: WatermarkPreview(
                imageProvider: const AssetImage('assets/sample.png'),
                watermarks: [
                  WatermarkItem(
                    widget: _buildBadgeWatermark('Preview Mode'),
                    size: const Size(220, 58),
                    layout: WatermarkLayout.aligned(
                      Alignment.topCenter,
                      padding: const EdgeInsets.all(16),
                    ),
                    opacity: 0.95,
                  ),
                  WatermarkItem(
                    widget: const Center(
                      child: Text(
                        'DEMO',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    size: const Size(150, 60),
                    layout: WatermarkLayout.diagonal(
                      spacing: const Size(90, 90),
                    ),
                    opacity: 0.12,
                    rotation: -0.55,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildActions(),
          const SizedBox(height: 12),
          Material(
            color: Colors.blueGrey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Expanded(child: Text(_status)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildPanel(
                    bytes: _sourceBytes,
                    emptyText: 'Source image is not loaded yet.',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPanel(
                    bytes: _resultBytes,
                    emptyText: 'Processed result will appear here.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_widget_watermark example'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Demo'),
            Tab(text: 'Bytes'),
            Tab(text: 'URL / Path'),
            Tab(text: 'Preview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOutputTab(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Bytes example', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('Use the “Bytes / Single” button in the Demo tab. The source image is loaded from an asset into Uint8List, then passed into WidgetWatermark.applyToBytes().'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('URL / Path example', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('Use the “URL / Diagonal” button to test applyFromUrl(), and “Path / Grid” to test applyFromPath() after writing the asset to a temporary file.'),
              ],
            ),
          ),
          _buildPreviewTab(),
        ],
      ),
    );
  }
}
