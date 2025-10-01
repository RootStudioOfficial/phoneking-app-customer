import 'package:flutter/material.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Rewards', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: _SegmentedTabBar(controller: _tab),
          ),
        ),
      ),
      body: TabBarView(controller: _tab, children: const [_RewardStoreTab(), _RedeemedTab(), _UsedTab()]),
    );
  }
}

// -------------------------------------------------------------
// Used tab (dim image + "Used" overlay like the mock)
// -------------------------------------------------------------
class _UsedTab extends StatelessWidget {
  const _UsedTab();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _UsedItem(
        title: '20% Screen Protector',
        desc: 'iphone 14 screen repaired.',
        dateText: 'Redeemed on Sep 12, 2025',
        pointsText: '2,000 pts',
        isUsed: true,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemBuilder: (_, i) => _UsedCard(item: items[i]),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length,
    );
  }
}

class _UsedItem {
  final String title;
  final String desc;
  final String dateText;
  final String pointsText;
  final bool isUsed;

  const _UsedItem({required this.title, required this.desc, required this.dateText, required this.pointsText, this.isUsed = true});
}

class _UsedCard extends StatelessWidget {
  final _UsedItem item;

  const _UsedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with dim + "Used" overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Replace Placeholder with Image.asset(...)
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.black26, // dim
                      BlendMode.darken,
                    ),
                    child: const Placeholder(),
                  ),
                  if (item.isUsed)
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Used',
                        style: TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Text(item.desc, style: const TextStyle(color: Color(0xFF6B7280), height: 1.35)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset(AssetImageUtils.confirmRedeemIcon, width: 16, height: 16, color: const Color(0xFF98A2B3)),
                    const SizedBox(width: 6),
                    Text(
                      item.dateText,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF98A2B3), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(AssetImageUtils.confirmRedeemIcon, width: 18, height: 18, color: const Color(0xFFFFC107)),
                    const SizedBox(width: 6),
                    Text(
                      item.pointsText,
                      style: const TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w800),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _RedeemedTab extends StatelessWidget {
  const _RedeemedTab();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _RedeemedItem(title: '20% Screen Protector', desc: 'iphone 14 screen repaired.', dateText: 'Redeemed on Sep 12, 2025', pointsText: '2,000 pts'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemBuilder: (_, i) => _RedeemedCard(item: items[i]),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length,
    );
  }
}

class _RedeemedItem {
  final String title;
  final String desc;
  final String dateText; // already formatted
  final String pointsText; // e.g. "2,000 pts"
  const _RedeemedItem({required this.title, required this.desc, required this.dateText, required this.pointsText});
}

class _RedeemedCard extends StatelessWidget {
  final _RedeemedItem item;

  const _RedeemedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: const Placeholder(), // swap with Image.asset(...)
            ),
          ),
          const SizedBox(width: 12),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),

                // Description
                Text(item.desc, style: const TextStyle(color: Color(0xFF6B7280), height: 1.35)),
                const SizedBox(height: 8),

                // Calendar row
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF98A2B3)),
                    const SizedBox(width: 6),
                    Text(
                      item.dateText,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF98A2B3), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Points row with star
                Row(
                  children: [
                    const Icon(Icons.star, size: 20, color: Color(0xFFFFC107)),
                    const SizedBox(width: 6),
                    Text(
                      item.pointsText,
                      style: const TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ----- Reward Store (cards + horizontal lists) -----
class _RewardStoreTab extends StatelessWidget {
  const _RewardStoreTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: const [
        _SectionBlock(brand: "PhoneKing"),
        SizedBox(height: 16),
        _SectionBlock(brand: "KingPlus"),
        SizedBox(height: 16),
        _SectionBlock(brand: "GadgetPlus"),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String brand;

  const _SectionBlock({required this.brand});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _RewardItem(name: "Screen Protector", pts: "1,000 pts"),
      _RewardItem(name: "Phone Case", pts: "1,000 pts"),
      _RewardItem(name: "Charger", pts: "1,200 pts"),
      _RewardItem(name: "Earbuds", pts: "2,000 pts"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                const Icon(Icons.phone_android, color: Color(0xFF0C34FF), size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    brand,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF0C34FF)),
                  icon: const Text("View All"),
                  label: const Icon(Icons.arrow_outward_rounded, size: 16),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 230,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => _RewardCard(item: items[i % items.length]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final _RewardItem item;

  const _RewardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: const Placeholder(), // swap with Image.asset(...)
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.pts,
              style: const TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardItem {
  final String name;
  final String pts;

  const _RewardItem({required this.name, required this.pts});
}

/// ----- iOS-like segmented control look (no packages) -----
class _SegmentedTabBar extends StatelessWidget {
  final TabController controller;

  const _SegmentedTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    const selected = Color(0xFF0C34FF);
    const bg = Color(0xFFF0F1F6);

    return Container(
      height: 44,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(22)),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: selected,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x260C34FF), blurRadius: 8, offset: Offset(0, 4))],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF5B667A),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: "Reward Store"),
          Tab(text: "Redeemed"),
          Tab(text: "Used"),
        ],
      ),
    );
  }
}
