import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phonekingcustomer/page/index_page.dart';
import 'package:phonekingcustomer/utils/extensions/navigation_extensions.dart';
import 'package:phonekingcustomer/widgets/cache_network_image_widget.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({super.key, required this.bannerImageUrl});

  final String bannerImageUrl;

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  int _left = 4;

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        context.navigateToNextPageWithRemoveUntil(IndexPage());
      } else {
        setState(() => _left--);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: 3 / 1,
              child: CacheNetworkImageWidget(url: widget.bannerImageUrl, fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: GestureDetector(
                onTap: () {
                  context.navigateToNextPageWithRemoveUntil(IndexPage());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(18)),
                  child: Text(
                    "Skip in $_left${_left == 1 ? 's' : 's'}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
