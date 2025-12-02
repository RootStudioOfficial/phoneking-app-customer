import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/reward/phone_king_reward_model_impl.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_vo.dart';
import 'package:phone_king_customer/data/vos/store_vo/store_vo.dart';
import 'package:phone_king_customer/page/reward/reward_details_page.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/widgets/cache_network_image_widget.dart';

class StoreViewAllPage extends StatefulWidget {
  const StoreViewAllPage({super.key, required this.stores});

  final List<StoreVO> stores;

  @override
  State<StoreViewAllPage> createState() => _StoreViewAllPageState();
}

// ========= Typography helper =========

class _StoreViewAllTextStyles {
  static const storeHeaderName = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 6,
        offset: Offset(0, 1),
      ),
    ],
  );

  static const dropdownItem = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
  );

  static const errorText = TextStyle(
    fontSize: 14,
    color: Color(0xFFB00020),
    fontWeight: FontWeight.w500,
  );

  static const retryButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const emptyText = TextStyle(
    fontSize: 14,
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  );

  static const productName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const productPoints = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xFFFF5722),
  );
}

class _StoreViewAllPageState extends State<StoreViewAllPage> {
  final _rewardModel = PhoneKingRewardModelImpl();

  String? selectedStoreId;

  String selectedCategory = _categories.first;

  bool _loading = false;
  String? _error;
  List<RewardVO> _rewards = const [];

  static const List<String> _categories = <String>[
    'Discount Voucher',
    'Free Product',
    'Free Service',
    'Cashback',
    'Gift Card',
    'Service Upgrade',
    'Special Access',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.stores.isNotEmpty) {
      // init with first store's ID
      selectedStoreId = widget.stores.first.id;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchRewards());
  }

  StoreVO? get _selectedStoreVo {
    if (selectedStoreId == null || widget.stores.isEmpty) return null;
    try {
      return widget.stores.firstWhere((s) => s.id == selectedStoreId);
    } catch (_) {
      return widget.stores.first;
    }
  }

  String _mapCategoryToApi(String uiValue) {
    // Convert "Discount Voucher" -> "DISCOUNT_VOUCHER"
    return uiValue.replaceAll(' ', '_').toUpperCase();
  }

  Future<void> _fetchRewards() async {
    if (selectedStoreId == null || (selectedStoreId?.isEmpty ?? true)) {
      setState(() {
        _rewards = const [];
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rewardType = _mapCategoryToApi(selectedCategory);

      // Your new method (positional args): getAllReward(storeID, rewardType)
      final res = await _rewardModel.getAllReward(selectedStoreId!, rewardType);

      if (!mounted) return;
      setState(() {
        _rewards = res.data ?? const [];
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
    final selected = _selectedStoreVo;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 380,
              pinned: false,
              floating: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CacheNetworkImageWidget(
                        url: selected?.bannerUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                      // Optional overlay for readability
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.10),
                                Colors.black.withValues(alpha: 0.35),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if ((selected?.name ?? '').isNotEmpty)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              selected?.name ?? "",
                              style: _StoreViewAllTextStyles.storeHeaderName,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Filter dropdowns
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    // Store dropdown (value = storeId, label = store.name)
                    Expanded(
                      child: _buildStoreDropdown(
                        value: selectedStoreId,
                        items: widget.stores
                            .map((s) => MapEntry(s.id ?? '', s.name ?? ''))
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null || value.isEmpty) return;
                          setState(() => selectedStoreId = value);
                          _fetchRewards();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Category dropdown (human readable -> uppercase for API)
                    Expanded(
                      child: _buildCategoryDropdown(
                        value: selectedCategory,
                        items: _categories,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedCategory = value);
                          _fetchRewards();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading / error / empty states
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Error: $_error',
                        textAlign: TextAlign.center,
                        style: _StoreViewAllTextStyles.errorText,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchRewards,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFED5B23),
                        ),
                        child: const Text(
                          'Retry',
                          style: _StoreViewAllTextStyles.retryButton,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_rewards.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Center(
                      child: Text(
                        'No rewards found',
                        style: _StoreViewAllTextStyles.emptyText,
                      ),
                    ),
                  ),
                )
              else
              // Product grid bound to API rewards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final r = _rewards[index];
                      return GestureDetector(
                        onTap: () {
                          context.navigateToNextPage(
                            RewardDetailsPage(rewardID: r.id ?? ''),
                          );
                        },
                        child: _buildProductCard(
                          name: r.name ?? '',
                          imageUrl: r.imageUrl ?? '',
                          points: '${r.requiredPoints} pts',
                        ),
                      );
                    }, childCount: _rewards.length),
                  ),
                ),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
    );
  }

  // ===== UI helpers =====

  Widget _buildStoreDropdown({
    required String? value,
    required List<MapEntry<String, String>> items, // id + name
    required ValueChanged<String?> onChanged,
  }) {
    // Keep current value if present; else fall back to first item (if any)
    final hasValue = items.any((e) => e.key == value);
    final safeValue =
    hasValue ? value : (items.isNotEmpty ? items.first.key : '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: items.map((e) {
            return DropdownMenuItem<String?>(
              value: e.key, // storeId (unique even if names duplicate)
              child: Text(
                e.value, // store name for display
                style: _StoreViewAllTextStyles.dropdownItem,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : items.firstOrNull ?? '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: items.map((String item) {
            return DropdownMenuItem<String?>(
              value: item,
              child: Text(
                item,
                style: _StoreViewAllTextStyles.dropdownItem,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String imageUrl,
    required String points,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: imageUrl.isEmpty
                  ? Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              )
                  : CacheNetworkImageWidget(
                url: imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Product info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _StoreViewAllTextStyles.productName,
                ),
                const SizedBox(height: 6),
                Text(
                  points,
                  style: _StoreViewAllTextStyles.productPoints,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tiny extension if you don't have firstOrNull in your codebase
extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
