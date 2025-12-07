import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/banner/phone_king_banner_model_impl.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/data/model/store/phone_king_store_model_impl.dart';
import 'package:phone_king_customer/data/vos/banner_vo/banner_vo.dart';
import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_vo.dart';
import 'package:phone_king_customer/data/vos/store_vo/store_vo.dart';
import 'package:phone_king_customer/page/auth/onboarding_page.dart';
import 'package:phone_king_customer/page/home/activity/activity_page.dart';
import 'package:phone_king_customer/page/home/qr_code/qrcode_page.dart';
import 'package:phone_king_customer/page/home/notification/notification_page.dart';
import 'package:phone_king_customer/page/home/scan_to_pay/payment_qr_scan_page.dart';
import 'package:phone_king_customer/page/home/store_view_all_page.dart';
import 'package:phone_king_customer/page/reward/reward_details_page.dart';
import 'package:phone_king_customer/persistent/language_persistent.dart';
import 'package:phone_king_customer/persistent/login_persistent.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';
import 'package:phone_king_customer/widgets/cache_network_image_widget.dart';
import 'package:phone_king_customer/widgets/session_time_out_dialog_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomeTextStyles {
  static const balanceLabel = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const balanceValue = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.w800,
  );

  static const activityButton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFF111827),
  );

  static const actionLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const bannerPlaceholder = TextStyle(
    fontSize: 14,
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  );

  static const storeName = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Color(0xFF111827),
  );

  static const viewAll = TextStyle(
    color: Color(0xFF0C34FF),
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static const rewardName = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Color(0xFF111827),
  );

  static const rewardPoints = TextStyle(
    color: Color(0xFF0C34FF),
    fontWeight: FontWeight.w700,
    fontSize: 13,
  );

  static const noData = TextStyle(
    fontSize: 14,
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  );

  static const errorMessage = TextStyle(
    fontSize: 14,
    color: Color(0xFFB00020),
    fontWeight: FontWeight.w500,
  );

  static const errorButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

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

  static const String _bannerTypeAnnouncement = 'ANNOUNCEMENT';

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
      final resBanners = await _bannerModel.getBanners(
        bannerType: _bannerTypeAnnouncement,
      );
      final resStores = await _storeModel.getStores();

      if (!mounted) return;
      setState(() {
        _balance = resBalance.data;
        _banners = resBanners.data ?? const [];
        _stores = resStores.data ?? const [];
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

  static String _formatPoints(int pts) {
    final s = pts.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final l10n = LocalizationString.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            Image.asset(AssetImageUtils.appLogo, width: 150),
            const SizedBox(width: 10),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showLanguageSelectBottomSheet(context);
            },
            icon: Image.asset(
              AssetImageUtils.translateIcon,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () =>
                context.navigateToNextPage(const NotificationPage()),
            icon: Image.asset(
              AssetImageUtils.notificationIcon,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _loading
            ? const _HomeSkeleton()
            : _error != null
            ? _ErrorView(message: _error!, onRetry: _loadAll)
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Points Balance =====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFED5B23),
                      Color(0xFFFFA86B),
                      Color(0xFFB85C32),
                    ],
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
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homePointBalance,
                              // "Point Balance"
                              style: _HomeTextStyles.balanceLabel,
                            ),
                            Text(
                              _formatPoints(
                                  _balance?.totalBalance ?? 0),
                              style: _HomeTextStyles.balanceValue,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            context.navigateToNextPage(
                              const ActivityPage(),
                            );
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n.homeActivity,
                                // "Activity"
                                style:
                                _HomeTextStyles.activityButton,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(
                          AssetImageUtils.qrIcon,
                          l10n.homeQrCode, // "QR Code"
                              () {
                            context.navigateToNextPage(
                              const QrCodePage(),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _actionButton(
                          AssetImageUtils.scanQrIcon,
                          l10n.homeScanToPay, // "Scan to Pay"
                              () {
                            context.navigateToNextPage(
                              const PaymentQrScanPage(),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== Banners =====
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: w * 0.5,
                    child: _banners.isEmpty
                        ? Container(
                      color: Colors.black12,
                      child: const Center(
                        child: Text(
                          "Banner Placeholder",
                          style: _HomeTextStyles
                              .bannerPlaceholder,
                        ),
                      ),
                    )
                        : PageView.builder(
                      onPageChanged: (index) {
                        if (mounted) {
                          setState(() {
                            _bannerActiveIndex = index;
                          });
                        }
                      },
                      itemCount: _banners.length,
                      itemBuilder: (context, i) {
                        final b = _banners[i];
                        final img = b.imageUrl;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(16),
                            child: CacheNetworkImageWidget(
                              url: img,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_banners.isEmpty)
                    const SizedBox.shrink()
                  else
                    AnimatedSmoothIndicator(
                      activeIndex: _bannerActiveIndex,
                      count: _banners.length,
                      effect: const WormEffect(
                        dotWidth: 10,
                        dotHeight: 10,
                        activeDotColor: Color(0xFFED5B23),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // ===== Stores (each with its Reward list) =====
              if (_stores.isEmpty)
                const SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      "No stores available",
                      style: _HomeTextStyles.noData,
                    ),
                  ),
                )
              else
                ..._stores
                    .map(
                      (s) => _storeSection(
                    context,
                    s,
                        () {
                      context.navigateToNextPage(
                        StoreViewAllPage(stores: _stores),
                      );
                    },
                  ),
                )
                    .expand((w) => [w, const SizedBox(height: 16)]),

              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Sections ----------

  Widget _storeSection(
      BuildContext context,
      StoreVO store,
      Function onTapViewAll,
      ) {
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
        children: [
          _storeHeader(context, store, onTapViewAll),
          const SizedBox(height: 12),
          _rewardGrid(rewards),
        ],
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _storeHeader(
      BuildContext context,
      StoreVO store,
      Function onTapViewAll,
      ) {
    final l10n = LocalizationString.of(context);

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
                      child: CacheNetworkImageWidget(
                        url: store.logoUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  store.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _HomeTextStyles.storeName,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              onTapViewAll();
            },
            child: Text(
              '${l10n.homeViewAll} →',
              // "View All →"
              style: _HomeTextStyles.viewAll,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardGrid(List<RewardVO> rewards) {
    if (rewards.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text("No rewards available", style: _HomeTextStyles.noData),
        ),
      );
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
                context.navigateToNextPage(
                  RewardDetailsPage(rewardID: r.id ?? ''),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 130,
                      child: (r.imageUrl ?? '').isEmpty
                          ? const Center(
                        child: Text(
                          "Image",
                          style: _HomeTextStyles.noData,
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.all(10),
                        child: CacheNetworkImageWidget(
                          url: r.imageUrl!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // name
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      r.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _HomeTextStyles.rewardName,
                    ),
                  ),
                  // points
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "${r.requiredPoints} pts",
                      style: _HomeTextStyles.rewardPoints,
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

  static Widget _actionButton(
      String iconPath,
      String label,
      VoidCallback onPressed,
      ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0C34FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        icon: Image.asset(iconPath, width: 20, height: 20),
        label: Text(label, style: _HomeTextStyles.actionLabel),
      ),
    );
  }
}

// ===== Small helpers for UX parity =====
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60),
        child: CircularProgressIndicator(),
      ),
    );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.message == 'session time out') {
        _showSessionTimeoutDialog(
          context,
          onRestart: () {
            LoginPersistent().clearLoginData();
            context.navigateToNextPageWithRemoveUntil(OnBoardingPage());
          },
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: _HomeTextStyles.errorMessage,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFED5B23),
              ),
              child: const Text("Retry", style: _HomeTextStyles.errorButton),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionTimeoutDialog(
      BuildContext context, {
        required VoidCallback onRestart,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SessionTimeoutDialog(),
    ).then((_) {
      onRestart();
    });
  }
}

class LanguageOption {
  final Locale locale;
  final String title;
  final String subtitle;
  final String flag;

  const LanguageOption({
    required this.locale,
    required this.title,
    required this.subtitle,
    required this.flag,
  });
}

Future<void> _showLanguageSelectBottomSheet(BuildContext context) async {
  final currentLocale = context.locale;
  final languageService = LanguagePersistent();

  const options = <LanguageOption>[
    LanguageOption(
      locale: Locale('en'),
      title: 'English',
      subtitle: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      locale: Locale('my'),
      title: 'Burmese',
      subtitle: 'မြန်မာ',
      flag: '🇲🇲',
    ),
  ];

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),

            ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected =
                    option.locale.languageCode == currentLocale.languageCode;

                return ListTile(
                  leading: Text(
                    option.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(option.title),
                  subtitle: Text(option.subtitle),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
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
