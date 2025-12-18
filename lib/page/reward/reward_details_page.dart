import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/data/model/reward/phone_king_reward_model_impl.dart';
import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_details_vo/reward_details_vo.dart';
import 'package:phone_king_customer/page/index_page.dart';
import 'package:phone_king_customer/page/reward/reward_scan_qr_code_page.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/widgets/cache_network_image_widget.dart';

class RewardDetailsPage extends StatefulWidget {
  const RewardDetailsPage({
    super.key,
    required this.rewardID,
    this.isRedeem = true,
  });

  final bool isRedeem;
  final String rewardID;

  @override
  State<RewardDetailsPage> createState() => _RewardDetailsPageState();
}

class _RewardDetailsPageState extends State<RewardDetailsPage> {
  final _rewardModel = PhoneKingRewardModelImpl();
  final _pointModel = PhoneKingPointModelImpl();

  bool _loading = true;
  String? _error;

  RewardDetailsVO? _details;
  GetBalanceVO? _balance;
  bool _redeemLoading = false;

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
      final resDetails =
      await _rewardModel.getRewardDetails(widget.rewardID);
      final resBalance = await _pointModel.getBalance();

      if (!mounted) return;
      setState(() {
        _details = resDetails.data;
        _balance = resBalance.data;
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

  bool get _canRedeem {
    if (_details == null || _balance == null) return false;
    if (_details!.availableQuantity <= 0) return false;
    return (_balance!.totalBalance) >= _details!.requiredPoints;
  }

  String _formatPoints(num pts) {
    final s = pts.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  String _titleCase(String s) {
    return s
        .toLowerCase()
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e.isEmpty
        ? e
        : '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final d = _details;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reward Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ✅ FIXED BOTTOM BUTTON
      bottomNavigationBar: d == null
          ? null
          : SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _redeemLoading
                  ? null
                  : () async {
                if (!widget.isRedeem) {
                  context.navigateToNextPage(
                    RewardScanQrCodePage(
                      redemptionId: d.id,
                    ),
                  );
                  return;
                }

                if (!_canRedeem) {
                  context.showErrorSnackBar(
                    'You cannot redeem this reward.',
                  );
                  return;
                }

                final proceed =
                await _showRedeemConfirmDialog(context);
                if (proceed != true) return;

                setState(() => _redeemLoading = true);
                try {
                  await _rewardModel.rewardRedeem(d.id);

                  if (context.mounted) {
                    context.showSuccessSnackBar(
                      'Redeemed successfully',
                    );
                    context
                        .navigateToNextPageWithRemoveUntil(
                      IndexPage(
                        desireIndex: 1,
                        desireRewardIndex: 1,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorSnackBar(e.toString());
                  }
                } finally {
                  if (mounted) {
                    setState(() => _redeemLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                (!_canRedeem && widget.isRedeem)
                    ? Colors.grey
                    : Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _redeemLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                widget.isRedeem ? 'Redeem' : 'Scan to Claim',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),

      // ✅ SCROLLABLE CONTENT
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
            ? ListView(
          children: [
            const SizedBox(height: 80),
            Center(child: Text(_error!)),
          ],
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 3:2 IMAGE
              AspectRatio(
                aspectRatio: 3 / 2,
                child: (d!.imageUrl ?? '').isEmpty
                    ? Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image, size: 48),
                  ),
                )
                    : CacheNetworkImageWidget(
                  url: d.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (d.rewardType.isNotEmpty)
                      Chip(
                        label:
                        Text(_titleCase(d.rewardType)),
                        backgroundColor:
                        Colors.deepOrange,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if ((d.description ?? '').isNotEmpty)
                      Text(
                        d.description!,
                        style: const TextStyle(
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 24),

                    _infoCard(
                      title: 'Points Required',
                      value:
                      '${_formatPoints(d.requiredPoints)} pts',
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      title: 'Your Balance',
                      value:
                      '${_formatPoints(_balance?.totalBalance ?? 0)} pts',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showRedeemConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Redeem'),
          content: const Text(
            'Are you sure you want to redeem this reward?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
