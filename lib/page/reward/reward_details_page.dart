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
  const RewardDetailsPage({super.key, required this.rewardID, this.redemptionId});

  final String rewardID;
  final String? redemptionId;

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
    if (widget.redemptionId?.isNotEmpty ?? false) return true;
    if (_details == null || _balance == null) return false;
    if ((_details!.availableQuantity ?? 0) <= 0) return false;
    return _balance!.totalBalance >= _details!.requiredPoints;
  }

  String _formatPoints(num n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final indexFromEnd = s.length - i;
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  String _titleCase(String s) =>
      s.toLowerCase().replaceAll('_', ' ').split(' ').map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}').join(' ');

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);
    final d = _details;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(l10n.rewardDetailsTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),

      /// Bottom CTA
      bottomNavigationBar: d == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _redeemLoading || !_canRedeem
                      ? null
                      : () async {
                          if (widget.redemptionId?.isNotEmpty ?? false) {
                            context.navigateToNextPage(RewardScanQrCodePage(redemptionId: widget.redemptionId!));
                            return;
                          }

                          final ok = await _showRedeemConfirmDialog(context);
                          if (ok != true) return;

                          setState(() => _redeemLoading = true);
                          try {
                            await _rewardModel.rewardRedeem(d.id);

                            if (!mounted) return;
                            context.showSuccessSnackBar(l10n.rewardDetailsRedeemSuccess);
                            context.navigateToNextPageWithRemoveUntil(IndexPage(desireIndex: 1, desireRewardIndex: 1));
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
                    backgroundColor: !_canRedeem ? Colors.grey : Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _redeemLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          (widget.redemptionId?.isEmpty ?? true) ? l10n.rewardDetailsRedeem : l10n.rewardDetailsScanToClaim,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
            ),

      /// Body
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
                  children: [_buildHeroImage(d!), _buildContentCard(context, d), const SizedBox(height: 120)],
                ),
              ),
      ),
    );
  }

  /// ================= UI SECTIONS =================

  Widget _buildHeroImage(RewardDetailsVO d) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: (d.imageUrl ?? '').isEmpty ? Container(color: Colors.grey.shade200) : CacheNetworkImageWidget(url: d.imageUrl!, fit: BoxFit.cover),
    );
  }

  Widget _buildContentCard(BuildContext context, RewardDetailsVO d) {
    final l10n = LocalizationString.of(context);

    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Row(
              spacing: 10,
              children: [
                Text(d.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                /// Service chip
                if (d.rewardType.isNotEmpty)
                  Flexible(
                    child: Chip(
                      label: Text(_titleCase(d.rewardType)),
                      backgroundColor: Colors.deepOrange,
                      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            /// Description
            if ((d.description ?? '').isNotEmpty) Text(d.description!, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),

            const SizedBox(height: 24),

            /// Points card
            _buildPointsCard(d),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.category, l10n.rewardDetailsCategory, _titleCase(d.rewardType)),
                  _infoRow(Icons.store, l10n.rewardDetailsBrand, d.store?.name ?? '-'),
                  _infoRow(
                    Icons.check_circle,
                    l10n.rewardDetailsAvailability,
                    (d.availableQuantity ?? 0) > 0 ? l10n.commonInStock : l10n.commonOutOfStock,
                    valueColor: (d.availableQuantity ?? 0) > 0 ? Colors.green : Colors.red,
                    iconColor: (d.availableQuantity ?? 0) > 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(RewardDetailsVO d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _pointsRow('Points Required', _formatPoints(d.requiredPoints), highlight: true),
          const Divider(height: 24),
          _pointsRow('Your Balance', '${_formatPoints(_balance?.totalBalance ?? 0)} pts'),
        ],
      ),
    );
  }

  Widget _pointsRow(String title, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          value,
          style: TextStyle(fontSize: highlight ? 18 : 14, fontWeight: FontWeight.bold, color: highlight ? Colors.deepOrange : Colors.black),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String title, String value, {Color? valueColor, Color? iconColor}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: iconColor ?? Colors.grey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        value,
        style: TextStyle(color: valueColor ?? Colors.grey.shade700, fontWeight: FontWeight.w600),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 8),
    //   child: Row(
    //     children: [
    //       Icon(icon, size: 20, color: Colors.grey),
    //       const SizedBox(width: 12),
    //       Expanded(
    //         child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    //       ),
    //       Text(
    //         value,
    //         style: TextStyle(color: valueColor ?? Colors.grey.shade700, fontWeight: FontWeight.w600),
    //       ),
    //     ],
    //   ),
    // );
  }

  /// ================= DIALOG =================

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
