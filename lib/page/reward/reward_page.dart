import 'dart:async';
import 'package:flutter/material.dart';

import 'package:phonekingcustomer/data/model/store/phone_king_store_model_impl.dart';
import 'package:phonekingcustomer/data/model/reward/phone_king_reward_model_impl.dart';
import 'package:phonekingcustomer/data/vos/store_vo/store_vo.dart';
import 'package:phonekingcustomer/data/vos/reward_vo/reward_vo.dart';

import 'package:phonekingcustomer/page/home/store_view_all_page.dart';
import 'package:phonekingcustomer/page/reward/reward_details_page.dart';
import 'package:phonekingcustomer/utils/extensions/navigation_extensions.dart';
import 'package:phonekingcustomer/utils/localization_strings.dart';
import 'package:phonekingcustomer/widgets/cache_network_image_widget.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key, this.desireRewardIndex = 0});

  final int desireRewardIndex;

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.index = widget.desireRewardIndex;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(l10n.rewardsTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: _SegmentedTabBar(controller: _tab),
          ),
        ),
      ),
      body: TabBarView(controller: _tab, children: const [_RewardStoreTab(), _RedeemedTab(), _UsedTab()]),
    );
  }
}

/// ---------- Segmented Tab ----------
class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    return Container(
      height: 44,
      decoration: BoxDecoration(color: const Color(0xFFF0F1F6), borderRadius: BorderRadius.circular(22)),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(color: const Color(0xFFED5B23), borderRadius: BorderRadius.circular(22)),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF5B667A),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: l10n.rewardsStore),
          Tab(text: l10n.rewardsRedeemed),
          Tab(text: l10n.rewardsUsed),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Reward Store tab  -> getStores()
// -------------------------------------------------------------
class _RewardStoreTab extends StatefulWidget {
  const _RewardStoreTab();

  @override
  State<_RewardStoreTab> createState() => _RewardStoreTabState();
}

class _RewardStoreTabState extends State<_RewardStoreTab> {
  final _storeModel = PhoneKingStoreModelImpl();

  bool _loading = true;
  String? _error;
  List<StoreVO> _stores = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _storeModel.getStores();
      if (!mounted) return;
      setState(() {
        _stores = res.data ?? const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() => _load();

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text('Error: $_error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ],
      );
    }
    if (_stores.isEmpty) {
      return const Center(child: Text('No stores available'));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemBuilder: (_, i) {
          if (i <= _stores.length - 1) {
            return _storeSection(_stores[i], () {
              // Pass all stores so StoreViewAllPage can switch between them
              context.navigateToNextPage(StoreViewAllPage(stores: _stores));
            });
          }
          return const SizedBox(height: 100);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: _stores.length + 1,
      ),
    );
  }
}

// -------------------------------------------------------------
// Redeemed tab -> rewardModel.redeemReward()
// -------------------------------------------------------------
class _RedeemedTab extends StatefulWidget {
  const _RedeemedTab();

  @override
  State<_RedeemedTab> createState() => _RedeemedTabState();
}

class _RedeemedTabState extends State<_RedeemedTab> {
  final _rewardModel = PhoneKingRewardModelImpl();
  bool _loading = true;
  String? _error;
  List<RewardVO> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _rewardModel.redeemReward();
      if (!mounted) return;
      setState(() {
        _items = res.data ?? const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() => _load();

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text('Error: $_error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No redeemed rewards'));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemBuilder: (_, i) => _RedeemedCard(item: _items[i]),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _items.length,
      ),
    );
  }
}

class _RedeemedCard extends StatelessWidget {
  final RewardVO item;

  const _RedeemedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.navigateToNextPage(RewardDetailsPage(rewardID: item.id ?? "", redemptionId: item.redemptionId));
      },
      child: Container(
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
                child: (item.imageUrl ?? '').isEmpty
                    ? Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image, size: 28, color: Colors.grey)),
                      )
                    : CacheNetworkImageWidget(url: item.imageUrl!, fit: BoxFit.cover),
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
                    item.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  if ((item.description ?? '').isNotEmpty) Text(item.description!, style: const TextStyle(color: Color(0xFF6B7280), height: 1.35)),
                  const SizedBox(height: 8),

                  // Points row with star
                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Color(0xFFFFC107)),
                      const SizedBox(width: 6),
                      Text(
                        '${item.requiredPoints} pts',
                        style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Used tab -> rewardModel.getUsedRewards()
// -------------------------------------------------------------
class _UsedTab extends StatefulWidget {
  const _UsedTab();

  @override
  State<_UsedTab> createState() => _UsedTabState();
}

class _UsedTabState extends State<_UsedTab> {
  final _rewardModel = PhoneKingRewardModelImpl();
  bool _loading = true;
  String? _error;
  List<RewardVO> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _rewardModel.getUsedRewards();
      if (!mounted) return;
      setState(() {
        _items = res.data ?? const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() => _load();

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text('Error: $_error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No used rewards'));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemBuilder: (_, i) => _UsedCard(item: _items[i]),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _items.length,
      ),
    );
  }
}

class _UsedCard extends StatelessWidget {
  final RewardVO item;

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
                  (item.imageUrl ?? '').isEmpty
                      ? Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.image, size: 28, color: Colors.grey)),
                        )
                      : ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.black26, // dim
                            BlendMode.darken,
                          ),
                          child: CacheNetworkImageWidget(url: item.imageUrl!, fit: BoxFit.cover),
                        ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Used',
                      style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800),
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
                  item.name ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                if ((item.description ?? '').isNotEmpty) Text(item.description!, style: const TextStyle(color: Color(0xFF6B7280), height: 1.35)),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF98A2B3)),
                    SizedBox(width: 6),
                    Text(
                      'Redeemed',
                      // API doesn’t provide date in RewardVO; label only
                      style: TextStyle(fontSize: 13, color: Color(0xFF98A2B3), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Color(0xFFFFC107)),
                    const SizedBox(width: 6),
                    Text(
                      '${item.requiredPoints} pts',
                      style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800),
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

// ---------- Sections ----------

Widget _storeSection(StoreVO store, VoidCallback onTapViewAll) {
  final rewards = store.rewards ?? const <RewardVO>[];

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE6E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_storeHeader(store, onTapViewAll), const SizedBox(height: 12), _rewardGrid(rewards)],
    ),
  );
}

// ---------- UI helpers ----------

Widget _storeHeader(StoreVO store, VoidCallback onTapViewAll) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if ((store.logoUrl ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CacheNetworkImageWidget(url: store.logoUrl!, fit: BoxFit.cover),
                  ),
                ),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                store.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onTapViewAll,
          child: const Text(
            "View All →",
            style: TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

Widget _rewardGrid(List<RewardVO> rewards) {
  if (rewards.isEmpty) {
    return const SizedBox(height: 120, child: Center(child: Text("No rewards available")));
  }

  return SizedBox(
    height: 240,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: rewards.length,
      itemBuilder: (context, i) {
        final r = rewards[i];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E8F0)),
          ),
          child: InkWell(
            onTap: () {
              context.navigateToNextPage(RewardDetailsPage(rewardID: r.id ?? ''));
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 130,
                    child: (r.imageUrl ?? '').isEmpty
                        ? const Center(child: Text("Image"))
                        : AspectRatio(
                            aspectRatio: 3 / 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: CacheNetworkImageWidget(url: r.imageUrl!, fit: BoxFit.contain),
                            ),
                          ),
                  ),
                ),
                // name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    r.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                // points
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "${r.requiredPoints} pts",
                    style: const TextStyle(color: Color(0xFF0C34FF), fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ),
  );
}
