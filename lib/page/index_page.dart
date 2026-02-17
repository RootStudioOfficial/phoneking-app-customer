import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phonekingcustomer/page/home/home_page.dart';
import 'package:phonekingcustomer/page/profile/profile_page.dart';
import 'package:phonekingcustomer/page/reward/reward_page.dart';
import 'package:phonekingcustomer/utils/asset_image_utils.dart';
import 'package:phonekingcustomer/utils/localization_strings.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key, this.desireIndex = 0, this.desireRewardIndex = 0});

  final int desireIndex;
  final int desireRewardIndex;

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  late int _currentIndex;
  late List<Widget> _pages;
  final GlobalKey<State<HomePage>> _homeKey = GlobalKey<State<HomePage>>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.desireIndex;
    _pages = <Widget>[
      HomePage(key: _homeKey),
      RewardsPage(desireRewardIndex: widget.desireRewardIndex),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = context.locale.languageCode;
    return Scaffold(
      body: Stack(
        children: [
          // Keep tab state alive
          IndexedStack(index: _currentIndex, children: _pages),

          // Glass bottom nav
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(
              key: ValueKey(localeCode),
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                if (index == 0) {
                  (_homeKey.currentState as dynamic)?.checkAppUpdate();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 105,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  _NavItem(index: 0, isSelected: currentIndex == 0, label: l10n.bottomNavHome, iconAsset: AssetImageUtils.homeIcon, onTap: onTap),
                  _NavItem(
                    index: 1,
                    isSelected: currentIndex == 1,
                    label: l10n.bottomNavRewards,
                    iconAsset: AssetImageUtils.rewardIcon,
                    onTap: onTap,
                  ),
                  _NavItem(
                    index: 2,
                    isSelected: currentIndex == 2,
                    label: l10n.bottomNavProfile,
                    iconAsset: AssetImageUtils.profileIcon,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.index, required this.isSelected, required this.label, required this.iconAsset, required this.onTap});

  final int index;
  final bool isSelected;
  final String label;
  final String iconAsset;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 0, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xFFFF7A33), Color(0xFFFF4E2E)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(23),
            boxShadow: isSelected ? const [BoxShadow(color: Color(0x33FF6A3A), blurRadius: 18, offset: Offset(0, 8))] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: isSelected ? 1.05 : 1.0,
                curve: Curves.easeOut,
                child: Image.asset(iconAsset, width: 22, height: 22, color: isSelected ? Colors.white : const Color(0xFF7C7E8C)),
              ),

              // Label (only when selected)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => SizeTransition(
                  sizeFactor: anim,
                  axis: Axis.horizontal,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: isSelected
                    ? Padding(
                        key: const ValueKey('label'),
                        padding: const EdgeInsets.only(left: 10),
                        child: DefaultTextStyle(
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2),
                          child: Text(label),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('nolabel')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
