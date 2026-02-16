import 'package:flutter/material.dart';
import 'package:phonekingcustomer/widgets/cache_network_image_widget.dart';

class RewardCardWidget extends StatelessWidget {
  const RewardCardWidget({super.key, required this.name, required this.imageUrl, required this.points, this.onTap});

  final String name;
  final String imageUrl;
  final String points;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E8F0)),
        ),
        child: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (3:2)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: imageUrl.isEmpty
                    ? const Center(child: Icon(Icons.image, size: 32, color: Colors.grey))
                    : CacheNetworkImageWidget(url: imageUrl, fit: BoxFit.contain),
              ),
            ),

            // Name
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827)),
            ),

            // Points
            Text(
              points,
              style: const TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w700, fontSize: 13),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
