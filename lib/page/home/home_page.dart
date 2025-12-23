import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/banner/phone_king_banner_model_impl.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/data/model/store/phone_king_store_model_impl.dart';
import 'package:phone_king_customer/data/vos/banner_vo/banner_vo.dart';
import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/data/vos/store_vo/store_vo.dart';
import 'package:phone_king_customer/page/auth/onboarding_page.dart';
import 'package:phone_king_customer/page/home/activity/activity_page.dart';
import 'package:phone_king_customer/page/home/notification/notification_page.dart';
import 'package:phone_king_customer/page/home/qr_code/qrcode_page.dart';
import 'package:phone_king_customer/page/home/scan_to_pay/payment_qr_scan_page.dart';
import 'package:phone_king_customer/page/home/store_view_all_page.dart';
import 'package:phone_king_customer/page/reward/reward_details_page.dart';
import 'package:phone_king_customer/persistent/language_persistent.dart';
import 'package:phone_king_customer/persistent/login_persistent.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';
import 'package:phone_king_customer/widgets/cache_network_image_widget.dart';
import 'package:phone_king_customer/widgets/reward_card_widget.dart';
import 'package:phone_king_customer/widgets/session_time_out_dialog_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ================= TEXT STYLES =================

class _HomeTextStyles {
  static const balanceLabel = TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500);
  static const balanceValue = TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800);
  static const activityButton = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111827));
  static const actionLabel = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black);
  static const bannerPlaceholder = TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500);
  static const storeName = TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF111827));
  static const viewAll = TextStyle(color: Color(0xFFED5B23), fontWeight: FontWeight.w600, fontSize: 13);
  static const noData = TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500);
  static const errorMessage = TextStyle(fontSize: 14, color: Color(0xFFB00020), fontWeight: FontWeight.w500);
  static const errorButton = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white);
}

// ================= STATE =================

class _HomePageState extends State<HomePage> {
  final _pointModel = PhoneKingPointModelImpl();
  final _bannerModel = PhoneKingBannerModelImpl();
  final _storeModel = PhoneKingStoreModelImpl();

  bool _loading = true;
  String? _error;

  GetBalanceVO? _balance;
  List<BannerVO> _banners = const [];
  List<StoreVO> _stores = const [];

  int _bannerActiveIndex = 0;

  static const _bannerTypeAnnouncement = 'ANNOUNCEMENT';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resBalance = await _pointModel.getBalance();
      final resBanners = await _bannerModel.getBanners(bannerType: _bannerTypeAnnouncement);
      final resStores = await _storeModel.getStores();

      if (!mounted) return;
      setState(() {
        _balance = resBalance.data;
        _banners = resBanners.data ?? [];
        _stores = resStores.data ?? [];
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

  Future<void> _onRefresh() => _loadAll();

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(children: [const SizedBox(width: 16), Image.asset(AssetImageUtils.appLogo, width: 150)]),
        actions: [
          IconButton(
            onPressed: () => _showLanguageSelectBottomSheet(context),
            icon: Image.asset(AssetImageUtils.translateIcon, width: 24),
          ),
          IconButton(
            onPressed: () => context.navigateToNextPage(const NotificationPage()),
            icon: Image.asset(AssetImageUtils.notificationIcon, width: 24),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _loading
            ? const _HomeSkeleton()
            : _error != null
            ? _ErrorView(message: _error!, onRetry: _loadAll)
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              _GreetingCard(balance: _balance?.totalBalance ?? 0),
              const SizedBox(height: 16),

              /// BANNERS
              SizedBox(
                height: w * 0.5,
                child: _banners.isEmpty
                    ? Center(child: Text(l10n.homeBannerPlaceholder, style: _HomeTextStyles.bannerPlaceholder))
                    : PageView.builder(
                  onPageChanged: (i) => setState(() => _bannerActiveIndex = i),
                  itemCount: _banners.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CacheNetworkImageWidget(
                        url: _banners[i].imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_banners.isNotEmpty)
                AnimatedSmoothIndicator(
                  activeIndex: _bannerActiveIndex,
                  count: _banners.length,
                  effect: const WormEffect(dotWidth: 10, dotHeight: 10, activeDotColor: Color(0xFFED5B23)),
                ),

              const SizedBox(height: 24),

              if (_stores.isEmpty)
                SizedBox(
                  height: 120,
                  child: Center(child: Text(l10n.homeNoStores, style: _HomeTextStyles.noData)),
                )
              else
                ..._stores.map((s) => _storeSection(context, s)).toList(),

              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeSection(BuildContext context, StoreVO store) {
    final l10n = LocalizationString.of(context);
    final rewards = store.rewards ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _storeHeader(context, store),
          const SizedBox(height: 12),
          rewards.isEmpty
              ? SizedBox(
            height: 120,
            child: Center(child: Text(l10n.homeNoRewards, style: _HomeTextStyles.noData)),
          )
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: rewards.length,
            itemBuilder: (_, i) {
              final r = rewards[i];
              return RewardCardWidget(
                name: r.name ?? '',
                imageUrl: r.imageUrl ?? '',
                points: '${r.requiredPoints} pts',
                onTap: () => context.navigateToNextPage(RewardDetailsPage(rewardID: r.id ?? '')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _storeHeader(BuildContext context, StoreVO store) {
    final l10n = LocalizationString.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(store.name ?? '', style: _HomeTextStyles.storeName),
          GestureDetector(
            onTap: () => context.navigateToNextPage(StoreViewAllPage(stores: _stores)),
            child: Text('${l10n.homeViewAll} →', style: _HomeTextStyles.viewAll),
          ),
        ],
      ),
    );
  }
}

// ================= OTHER WIDGETS =================

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Padding(padding: EdgeInsets.only(top: 60), child: CircularProgressIndicator()));
  }
}

class _ErrorView extends StatefulWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  State<_ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<_ErrorView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.message == 'session time out') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const SessionTimeoutDialog(),
        ).then((_) {
          LoginPersistent().clearLoginData();
          context.navigateToNextPageWithRemoveUntil(const OnBoardingPage());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.message, style: _HomeTextStyles.errorMessage),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: widget.onRetry,
            child: Text(l10n.commonRetry, style: _HomeTextStyles.errorButton),
          ),
        ],
      ),
    );
  }
}



class LanguageOption {
  final Locale locale;
  final String title;
  final String subtitle;
  final String flag;

  const LanguageOption({required this.locale, required this.title, required this.subtitle, required this.flag});
}

Future<void> _showLanguageSelectBottomSheet(BuildContext context) async {
  final currentLocale = context.locale;
  final languageService = LanguagePersistent();

  const options = <LanguageOption>[
    LanguageOption(locale: Locale('en'), title: 'English', subtitle: 'English', flag: '🇺🇸'),
    LanguageOption(locale: Locale('my'), title: 'Burmese', subtitle: 'မြန်မာ', flag: '🇲🇲'),
  ];

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 4),
            const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Divider(height: 1),

            ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option.locale.languageCode == currentLocale.languageCode;

                return ListTile(
                  leading: Text(option.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(option.title),
                  subtitle: Text(option.subtitle),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () async {
                    await context.setLocale(option.locale);

                    await languageService.setLocale(option.locale);

                    if (context.mounted) {
                      context.navigateBack();
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFED5B23), Color(0xFFFFA86B), Color(0xFFB85C32)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homePointBalance,
                    // "Point Balance"
                    style: _HomeTextStyles.balanceLabel,
                  ),
                  Text(_formatPoints(balance), style: _HomeTextStyles.balanceValue),
                ],
              ),
              GestureDetector(
                onTap: () {
                  context.navigateToNextPage(const ActivityPage());
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      l10n.homeActivity,
                      // "Activity"
                      style: _HomeTextStyles.activityButton,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                iconPath: AssetImageUtils.qrIcon,
                label: l10n.homeQrCode,
                onPressed: () {
                  context.navigateToNextPage(const QrCodePage());
                },
              ),
              const SizedBox(width: 12),

              _ActionButton(
                iconPath: AssetImageUtils.scanQrIcon,
                label: l10n.homeScanToPay,
                onPressed: () {
                  context.navigateToNextPage(const PaymentQrScanPage());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPoints(int pts) {
    final s = pts.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.iconPath, required this.label, required this.onPressed});

  final String iconPath;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0C34FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        icon: Image.asset(iconPath, width: 20, height: 20),
        label: Text(label, style: _HomeTextStyles.actionLabel),
      ),
    );
  }
}
