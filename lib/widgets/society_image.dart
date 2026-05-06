import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Cross-platform image renderer for society banners.
///
/// Renders the supplied [bytes] via `Image.memory` so the same widget works on
/// mobile, desktop and web — where `dart:io`'s `File` API throws
/// `Unsupported operation: _Namespace`. When [bytes] is null a gradient
/// placeholder with [Icons.groups] is shown instead.
class SocietyImage extends StatelessWidget {
  /// Raw image bytes obtained from `XFile.readAsBytes()`. Null shows the
  /// gradient placeholder.
  final Uint8List? bytes;

  /// Two-stop gradient used for the placeholder when no image is provided.
  final List<Color> gradientColors;

  /// Box height. Width always expands to fill the parent.
  final double height;

  /// Box fit applied to the rendered image.
  final BoxFit fit;

  const SocietyImage({
    super.key,
    required this.bytes,
    required this.gradientColors,
    this.height = 160,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: bytes != null
          ? Image.memory(bytes!, fit: fit)
          : _GradientPlaceholder(colors: gradientColors),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  final List<Color> colors;
  const _GradientPlaceholder({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.groups, size: 64, color: Colors.white),
      ),
    );
  }
}
