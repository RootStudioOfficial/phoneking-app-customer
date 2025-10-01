import 'package:flutter/material.dart';
import 'package:phone_king_customer/page/home/home_page.dart';
import 'package:phone_king_customer/page/profile/profile_page.dart';
import 'package:phone_king_customer/page/reward/reward_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';


class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentIndex = 0;

  final _pages = const [HomePage(), RewardsPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0C34FF),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(AssetImageUtils.homeIcon, width: 24, height: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(AssetImageUtils.rewardIcon, width: 24, height: 24),
            label: 'Gifts',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(AssetImageUtils.profileIcon, width: 24, height: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
