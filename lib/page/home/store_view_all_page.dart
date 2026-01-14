import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/reward/phone_king_reward_model_impl.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_vo.dart';
import 'package:phone_king_customer/data/vos/store_vo/store_vo.dart';
import 'package:phone_king_customer/page/reward/reward_details_page.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';
import 'package:phone_king_customer/widgets/cache_network_image_widget.dart';
import 'package:phone_king_customer/widgets/reward_card_widget.dart';

class StoreViewAllPage extends StatefulWidget {
  const StoreViewAllPage({super.key, required this.stores});

  final List<StoreVO> stores;

  @override
  State<StoreViewAllPage> createState() => _StoreViewAllPageState();
}

// ================= TEXT STYLES =================

class _StoreViewAllTextStyles {
  static const storeHeaderName = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    shadows: [Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1))],
  );

  static const dropdownItem = TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500);
  static const errorText = TextStyle(fontSize: 14, color: Color(0xFFB00020), fontWeight: FontWeight.w500);
  static const retryButton = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white);
  static const emptyText = TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500);
}

// ================= STATE =================

class _StoreViewAllPageState extends State<StoreViewAllPage> {
  final _rewardModel = PhoneKingRewardModelImpl();

  String? selectedStoreId;
  String selectedCategory = _categories.first;

  bool _loading = false;
  String? _error;
  List<RewardVO> _rewards = const [];

  static const List<String> _categories = ['All', 'Discount Voucher', 'Free Product', 'Free Service'];

  @override
  void initState() {
    super.initState();
    if (widget.stores.isNotEmpty) {
      selectedStoreId = widget.stores.first.id;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRewards());
  }

  StoreVO? get _selectedStore {
    if (selectedStoreId == null) return null;
    return widget.stores.firstWhere((s) => s.id == selectedStoreId, orElse: () => widget.stores.first);
  }

  String? _mapCategoryToApi(String ui) {
    if (ui == 'All') return null;
    return ui.replaceAll(' ', '_').toUpperCase();
  }

  Future<void> _fetchRewards() async {
    if (selectedStoreId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _rewardModel.getAllReward(selectedStoreId!, _mapCategoryToApi(selectedCategory));

      if (!mounted) return;
      setState(() {
        _rewards = res.data ?? [];
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

  Future<void> _onRefresh() => _fetchRewards();

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);
    final selected = _selectedStore;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // ================= HEADER =================
            SliverAppBar(
              expandedHeight: screenHeight / 3,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CacheNetworkImageWidget(url: selected?.bannerUrl ?? '', fit: BoxFit.cover),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.10), Colors.black.withValues(alpha: 0.35)],
                          ),
                        ),
                      ),
                    ),
                    if ((selected?.name ?? '').isNotEmpty)
                      Positioned(left: 16, bottom: 16, child: Text(selected!.name!, style: _StoreViewAllTextStyles.storeHeaderName)),
                  ],
                ),
              ),
            ),

            // ================= FILTERS =================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: _storeDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _categoryDropdown()),
                  ],
                ),
              ),
            ),

            // ================= CONTENT =================
            if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('${l10n.storeViewErrorPrefix}: $_error', textAlign: TextAlign.center, style: _StoreViewAllTextStyles.errorText),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchRewards,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFED5B23)),
                        child: Text(l10n.storeViewRetry, style: _StoreViewAllTextStyles.retryButton),
                      ),
                    ],
                  ),
                ),
              )
            else if (_rewards.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.storeViewNoRewards, style: _StoreViewAllTextStyles.emptyText)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final r = _rewards[i];
                    return RewardCardWidget(
                      name: r.name ?? '',
                      imageUrl: r.imageUrl ?? '',
                      points: '${r.requiredPoints} pts',
                      onTap: () => context.navigateToNextPage(RewardDetailsPage(rewardID: r.id ?? '')),
                    );
                  }, childCount: _rewards.length),
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }

  // ================= DROPDOWNS =================

  Widget _storeDropdown() {
    final items = widget.stores.map((s) => MapEntry(s.id ?? '', s.name ?? '')).toList();
    final value = items.any((e) => e.key == selectedStoreId) ? selectedStoreId : (items.isNotEmpty ? items.first.key : null);

    return _dropdown(
      value: value,
      items: items,
      onChanged: (v) {
        if (v == null) return;
        setState(() => selectedStoreId = v);
        _fetchRewards();
      },
    );
  }

  Widget _categoryDropdown() {
    return _dropdown(
      value: selectedCategory,
      items: _categories.map((e) => MapEntry(e, e)).toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => selectedCategory = v);
        _fetchRewards();
      },
    );
  }

  Widget _dropdown({required String? value, required List<MapEntry<String, String>> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem<String?>(
                  value: e.key,
                  child: Text(e.value, style: _StoreViewAllTextStyles.dropdownItem),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
