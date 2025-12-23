import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/data/model/reward/phone_king_reward_model_impl.dart';
import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_details_vo/reward_details_vo.dart';
import 'package:phone_king_customer/page/index_page.dart';
import 'package:phone_king_customer/page/reward/reward_scan_qr_code_page.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';
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
  bool _redeemLoading = false;
  String? _error;

  RewardDetailsVO? _details;
  GetBalanceVO? _balance;

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
      final detailsRes = await _rewardModel.getRewardDetails(widget.rewardID);
      final balanceRes = await _pointModel.getBalance();

      if (!mounted) return;
      setState(() {
        _details = detailsRes.data;
        _balance = balanceRes.data;
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
    return _balance!.totalBalance >= _details!.requiredPoints;
  }

  String _formatPoints(num n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  String _titleCase(String s) =>
      s.toLowerCase().replaceAll('_', ' ').split(' ').map((e) {
        if (e.isEmpty) return e;
        return '${e[0].toUpperCase()}${e.substring(1)}';
      }).join(' ');

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);
    final d = _details;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          l10n.rewardDetailsTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),

      bottomNavigationBar: d == null
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _redeemLoading
                ? null
                : () async {
              if (!widget.isRedeem) {
                context.navigateToNextPage(
                  RewardScanQrCodePage(redemptionId: d.id),
                );
                return;
              }

              if (!_canRedeem) {
                context.showErrorSnackBar(
                  l10n.rewardDetailsCannotRedeem,
                );
                return;
              }

              final ok = await _showRedeemConfirmDialog(context);
              if (ok != true) return;

              setState(() => _redeemLoading = true);
              try {
                await _rewardModel.rewardRedeem(d.id);

                if (!mounted) return;
                context.showSuccessSnackBar(
                  l10n.rewardDetailsRedeemSuccess,
                );
                context.navigateToNextPageWithRemoveUntil(
                  IndexPage(desireIndex: 1, desireRewardIndex: 1),
                );
              } catch (e) {
                if (mounted) {
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
              (!_canRedeem && widget.isRedeem) ? Colors.grey : Colors.deepOrange,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _redeemLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Text(
              widget.isRedeem
                  ? l10n.rewardDetailsRedeem
                  : l10n.rewardDetailsScanToClaim,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(children: [Center(child: Text(_error!))])
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 3 / 2,
                child: (d!.imageUrl ?? '').isEmpty
                    ? Container(color: Colors.grey.shade200)
                    : CacheNetworkImageWidget(url: d.imageUrl!, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (d.rewardType.isNotEmpty)
                      Chip(
                        label: Text(_titleCase(d.rewardType)),
                        backgroundColor: Colors.deepOrange,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    const SizedBox(height: 16),
                    if ((d.description ?? '').isNotEmpty)
                      Text(d.description!, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    _infoCard(
                      title: l10n.rewardDetailsPointsRequired,
                      value: '${_formatPoints(d.requiredPoints)} pts',
                    ),
                    const SizedBox(height: 12),
                    _infoCard(
                      title: l10n.rewardDetailsYourBalance,
                      value: '${_formatPoints(_balance?.totalBalance ?? 0)} pts',
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

  Widget _infoCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ],
      ),
    );
  }

  Future<bool?> _showRedeemConfirmDialog(BuildContext context) {
    final l10n = LocalizationString.of(context);
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.rewardDetailsConfirmTitle),
        content: Text(l10n.rewardDetailsConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonNo)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonYes)),
        ],
      ),
    );
  }
}
