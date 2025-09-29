import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CacheNetworkImageWidget extends StatelessWidget {
  const CacheNetworkImageWidget({super.key, required this.url, this.width, this.height, this.fit, this.radius}) : isFullCircleShape = false;

  const CacheNetworkImageWidget.fullCircleShape({super.key, required this.url, this.fit, this.radius})
    : isFullCircleShape = true,
      width = null,
      height = null;

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final double? radius;
  final bool isFullCircleShape;

  @override
  Widget build(BuildContext context) {
    final double effectiveRadius = radius ?? 25;

    return ClipRRect(
      borderRadius: BorderRadius.circular(isFullCircleShape ? effectiveRadius : (radius ?? 0)),
      child: CachedNetworkImage(
        imageUrl: url,
        width: isFullCircleShape ? effectiveRadius * 2 : width,
        height: isFullCircleShape ? effectiveRadius * 2 : height,
        fit: fit,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => const Center(child: Icon(Icons.error)),
        imageBuilder:
            isFullCircleShape
                ? (context, imageProvider) {
                  return Container(
                    width: effectiveRadius * 2,
                    height: effectiveRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: DecorationImage(image: imageProvider, fit: fit ?? BoxFit.cover),
                    ),
                  );
                }
                : null,
      ),
    );
  }
}
