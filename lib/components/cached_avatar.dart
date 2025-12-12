import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData? placeholderIcon;
  final Color? backgroundColor;

  const CachedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 35,
    this.placeholderIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: Icon(
          placeholderIcon,
          size: radius,
          color: Colors.grey[600],
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: backgroundColor,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[200],
        child: SizedBox(
          width: radius * 0.5,
          height: radius * 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.grey[400]!,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: Icon(
          placeholderIcon,
          size: radius,
          color: Colors.grey[600],
        ),
      ),
      // Cache configuration
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      memCacheWidth: (radius * 2 * 3).toInt(), // 3x for retina displays
      memCacheHeight: (radius * 2 * 3).toInt(),
    );
  }
}

/// Cached Image Widget for rectangular images
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
        child: const Icon(
          Icons.broken_image,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.grey,
          ),
        ),
        // Cache configuration
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        memCacheWidth: width != null ? (width! * 3).toInt() : null,
        memCacheHeight: height != null ? (height! * 3).toInt() : null,
      ),
    );
  }
}