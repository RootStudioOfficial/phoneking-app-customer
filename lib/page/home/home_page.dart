import 'package:flutter/material.dart';
import 'package:phone_king_customer/page/home/my_history_page.dart';
import 'package:phone_king_customer/page/home/my_qrcode_page.dart';
import 'package:phone_king_customer/page/home/notification/notification_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            // Brand mark
            Image.asset(AssetImageUtils.appLogo, width: 150),
            const SizedBox(width: 10),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Image.asset(AssetImageUtils.translateIcon, width: 24, height: 24)),
          const SizedBox(width: 8),
          IconButton(onPressed: () {
            context.navigateToNextPage(NotificationPage());
          }, icon: Image.asset(AssetImageUtils.notificationIcon, width: 24, height: 24)),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points Balance Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFED5B23), Color(0xFFED5B23), Color(0xFFED5B23)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(AssetImageUtils.goldSetIcon, width: 20, height: 20),
                      Text(
                        "Gold",
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Point Balance", style: TextStyle(color: Colors.white)),
                      const Text(
                        "11,968",
                        style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(AssetImageUtils.qrIcon, "QR Code", () {
                        context.navigateToNextPage(MyQrCodePage());
                      }),
                      const SizedBox(width: 12),
                      _actionButton(AssetImageUtils.historyIcon, "History", () {
                        context.navigateToNextPage(MyHistoryPage());
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Banner / Carousel placeholder
            SizedBox(
              height: w * 0.5,
              child: PageView(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.black12,
                        child: const Center(child: Text("Banner Placeholder")),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Grid (PhoneKing section)
            _sectionHeader(AssetImageUtils.appLogo),
            const SizedBox(height: 12),
            _productGrid(),

            const SizedBox(height: 24),

            // Another section example
            _sectionHeader(AssetImageUtils.appLogo),
            const SizedBox(height: 12),
            _productGrid(),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 150),
          const Text(
            "View All →",
            style: TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _productGrid() {
    final products = [
      {"name": "Screen Protector", "pts": "1,000 pts"},
      {"name": "Phone Case", "pts": "1,000 pts"},
      {"name": "Charger", "pts": "1,200 pts"},
      {"name": "Earbuds", "pts": "2,000 pts"},
    ];

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 130,
                    color: Colors.black12,
                    child: const Placeholder(), // Replace with product image
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    p['pts']!,
                    style: const TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _actionButton(String iconPath, String label, Function onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0C34FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        icon: Image.asset(iconPath, width: 20, height: 20),
        label: Text(label, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
