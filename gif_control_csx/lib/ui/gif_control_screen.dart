import 'package:flutter/widgets.dart';
import 'package:gif_control_csx/controller/gif_controller.dart';
import 'package:gif_control_csx/model/gif_cache.dart';
import 'package:gif_control_csx/tool/git_normal_tool.dart';

class GifImageCsx extends StatefulWidget {
  final GifController controller;
  final ImageProvider image;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool excludeFromSemantics;
  final VoidCallback? onFetchCompleted;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final Rect? centerSlice;
  final String? semanticLabel;

  const GifImageCsx({
    required this.image,
    required this.controller,
    Key? key,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.onFetchCompleted,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
  }) : super(key: key);

  @override
  State<GifImageCsx> createState() => _GifImageCsxState();
}

class _GifImageCsxState extends State<GifImageCsx> {
  static GifCache cache = GifCache();

  List<ImageInfo>? _infos;
  int _curIndex = 0;
  bool _fetchComplete = false;
  ImageInfo? get _imageInfo {
    if (!_fetchComplete) return null;
    return _infos == null ? null : _infos![_curIndex];
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_listener);
  }

  @override
  void didUpdateWidget(GifImageCsx oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      GifNormalTool.fetchGif(widget.image, cache).then((imageInfors) {
        if (mounted) {
          setState(() {
            _infos = imageInfors;
            _fetchComplete = true;
            _curIndex = widget.controller.value.toInt();
            widget.onFetchCompleted?.call();
          });
        }
      });
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_listener);
      widget.controller.addListener(_listener);
    }
  }

  void _listener() {
    if (_curIndex != widget.controller.value && _fetchComplete) {
      if (mounted) {
        setState(() {
          _curIndex = widget.controller.value.toInt();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_infos == null) {
      GifNormalTool.fetchGif(widget.image, cache).then((imageInfors) {
        if (mounted) {
          setState(() {
            _infos = imageInfors;
            _fetchComplete = true;
            _curIndex = widget.controller.value.toInt();
            widget.onFetchCompleted?.call();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final RawImage image = RawImage(
      image: _imageInfo?.image,
      width: widget.width,
      height: widget.height,
      scale: _imageInfo?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
    );
    if (widget.excludeFromSemantics) {
      return image;
    }
    return Semantics(
      container: widget.semanticLabel != null,
      image: true,
      label: widget.semanticLabel ?? '',
      child: image,
    );
  }
}
