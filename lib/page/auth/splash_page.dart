import 'package:flutter/material.dart';
import 'package:phone_king_customer/page/auth/banner_page.dart';
import 'package:phone_king_customer/page/auth/onboarding_page.dart';
import 'package:phone_king_customer/persistent/login_persistent.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';

import 'package:phone_king_customer/data/model/banner/phone_king_banner_model.dart';
import 'package:phone_king_customer/data/model/banner/phone_king_banner_model_impl.dart';

import 'package:phone_king_customer/data/vos/banner_vo/banner_vo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  final PhoneKingBannerModel _bannerModel = PhoneKingBannerModelImpl();

  static const String _bannerType = 'SPLASH_SCREEN';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideNext());
  }

  Future<void> _decideNext() async {
    const splashHold = Duration(milliseconds: 650);

    bool loggedIn = false;
    try {
      loggedIn = await LoginPersistent().isLoggedIn();
    } catch (_) {
      loggedIn = false;
    }

    if (!loggedIn) {
      await Future<void>.delayed(splashHold);
      if (!mounted) return;
      _go(const OnBoardingPage());
      return;
    }

    try {
      final res = await _bannerModel.getBanners(bannerType: _bannerType);
      final banners = res.data ?? const <BannerVO>[];

      final String? firstImageUrl = banners.firstOrNull?.imageUrl;
      await Future<void>.delayed(splashHold);
      if (!mounted) return;

      if (firstImageUrl != null && firstImageUrl.isNotEmpty) {
        _go(BannerPage(bannerImageUrl: firstImageUrl));
      } else {
        _go(const BannerPage(bannerImageUrl: ''));
      }
    } catch (e) {
      await Future<void>.delayed(splashHold);
      if (!mounted) return;
      _go(const OnBoardingPage());
    }
  }

  void _go(Widget page) {
    try {
      context.navigateToNextPageWithRemoveUntil(page);
    } catch (_) {
      context.navigateToNextPageWithRemoveUntil(page);
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.0,
                  colors: [Color(0xFFDA6B1F), Color(0xFF0F0F0F)],
                  stops: [0.0, 0.55],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _ac, curve: Curves.easeOut),
              child: ScaleTransition(
                scale: CurvedAnimation(parent: _ac, curve: Curves.easeOutBack),
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: Image.asset(
                    AssetImageUtils.splashLogo,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 18, letterSpacing: 0.3),
                    children: [
                      TextSpan(
                        text: "PhoneKing",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: "Plus",
                        style: TextStyle(
                          color: Color(0xFFFE6A00),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
