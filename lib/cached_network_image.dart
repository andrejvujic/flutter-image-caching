import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

/// Created by Andrej
/// April 21, 2022

class CachedNetworkImage extends StatefulWidget {
  /// This class allows the caching of images.
  /// It looks for the image in the cache storage
  /// before downloading it from the URL. If the image
  /// is found it is shown directly from the cache,
  /// if not, it is downloaded, saved and then shown.
  final String url;
  final bool wantKeepAlive;
  final Widget errorWidget;

  /// Regarding CircularProgressIndicator:
  final double cpiMaxHeight, cpiMaxWidth, cpiStrokeWidth;
  final BoxFit fit;
  const CachedNetworkImage({
    Key key,
    @required this.url,
    this.wantKeepAlive = true,
    this.errorWidget,
    this.cpiMaxHeight,
    this.cpiMaxWidth,
    this.cpiStrokeWidth = 4.0,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage>
    with AutomaticKeepAliveClientMixin {
  Uint8List bytes;
  String url;

  static Uint8List get emptyUint8List => Uint8List.fromList(
        const <int>[],
      );

  /// If true, keeps the widget alive even when it is not in view.
  bool get wantKeepAlive =>
      widget.wantKeepAlive == null ? true : widget.wantKeepAlive;

  Future<void> prepareImage(String url) async {
    /// Fetches the image from the url and saves
    /// it into the cache storage.
    final _bytes = await fetchImage(url);

    setState(() => bytes = _bytes);

    if (_bytes.length > 0) await saveImage(url, _bytes);
  }

  Future<Uint8List> fetchImage(String url) async {
    /// Downloads the image from the given url.
    try {
      final uri = Uri.parse(url);
      final r = await http.get(uri);

      return r.statusCode == 200 ? r.bodyBytes : emptyUint8List;
    } catch (e) {
      return emptyUint8List;
    }
  }

  Future<void> saveImage(String url, Uint8List bytes) async {
    /// Saves the image data into cache.
    final box = Hive.box('cache');
    await box.put(
      url,
      {
        'bytes': bytes,
        'date': DateTime.now(),
        'url': url,
      },
    );
  }

  Uint8List loadImage(String url) {
    /// Loads the image data from cache.
    final box = Hive.box('cache');
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      box.get(url),
    );
    return data['bytes'];
  }

  Widget _buildErrorWidget() => widget.errorWidget == null
      ? const Icon(Icons.image, size: 30.0)
      : widget.errorWidget;

  @override
  void initState() {
    url = widget.url == null ? "" : widget.url;

    final box = Hive.box('cache');

    final bool _ = box.containsKey(
      url,
    );

    /// Loads the images from cache if it is present there.
    if (_) {
      setState(
        () => bytes = loadImage(url),
      );
    } else {
      prepareImage(url);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return bytes == null
        ? ConstrainedBox(
            constraints:
                widget.cpiMaxHeight == null || widget.cpiMaxWidth == null
                    ? BoxConstraints()
                    : BoxConstraints(
                        maxHeight: widget.cpiMaxHeight,
                        maxWidth: widget.cpiMaxWidth,
                      ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: widget.cpiStrokeWidth,
              ),
            ),
          )
        : bytes.length > 0
            ? Image.memory(
                bytes,
                fit: widget.fit,
              )
            : _buildErrorWidget();
  }
}
