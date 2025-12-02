import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/data/model/reward/phone_king_reward_model_impl.dart';
import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_details_vo/reward_details_vo.dart';
import 'package:phone_king_customer/page/index_page.dart';
import 'package:phone_king_customer/page/reward/reward_scan_qr_code_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
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
      final resDetails = await _rewardModel.getRewardDetails(widget.rewardID);
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

  // Helpers
  String _titleCaseFromSnakeOrUpper(String s) {
    if (s.isEmpty) return s;
    final parts = s.toLowerCase().replaceAll('_', ' ').split(' ');
    return parts
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
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

  Color _availabilityColor(int q) => q > 0 ? Colors.green : Colors.red;

  String _availabilityText(int q) => q > 0 ? 'In Stock' : 'Out of Stock';

  bool get _canRedeem {
    if (_details == null || _balance == null) return false;
    if (_details!.availableQuantity <= 0) return false;
    final userPts = _balance?.totalBalance ?? 0;
    return userPts >= _details!.requiredPoints;
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _loading
            ? const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 50),
            child: CircularProgressIndicator(),
          ),
        )
            : (_error != null)
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Error: $_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        )
            : (d == null)
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            Center(child: Text('No details found')),
          ],
        )
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image (from reward imageUrl)
              Container(
                width: double.infinity,
                height: 320,
                color: Colors.white,
                child: (d.imageUrl ?? '').isEmpty
                    ? Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 56,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : CacheNetworkImageWidget(
                  url: d.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Category Tag
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            d.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if ((d.rewardType).isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              _titleCaseFromSnakeOrUpper(
                                d.rewardType,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    if ((d.description ?? '').isNotEmpty)
                      Text(
                        d.description!,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Points Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Points Required
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Points Required:',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatPoints(
                                        d.requiredPoints),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Divider(
                            color: Colors.grey[300],
                            height: 1,
                          ),
                          const SizedBox(height: 16),

                          // Your Balance
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Balance:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${_formatPoints(_balance?.totalBalance ?? 0)} points',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          if (_details != null &&
                              _balance != null &&
                              !_canRedeem &&
                              widget.isRedeem) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _details!.availableQuantity <= 0
                                    ? 'This reward is currently out of stock.'
                                    : 'You don’t have enough points to redeem this reward.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Card (Category, Brand, Availability)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Category
                          _buildInfoRow(
                            icon: Icons.grid_view,
                            title: 'Category',
                            subtitle: _titleCaseFromSnakeOrUpper(
                              d.rewardType,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Brand (from store.name)
                          _buildInfoRow(
                            icon: Icons.store,
                            title: 'Brand',
                            subtitle: (d.store?.name ?? '—'),
                          ),

                          const SizedBox(height: 20),

                          // Availability (from availableQuantity)
                          _buildInfoRow(
                            icon: Icons.check_circle,
                            title: 'Availability',
                            subtitle: _availabilityText(
                              d.availableQuantity,
                            ),
                            iconColor: _availabilityColor(
                              d.availableQuantity,
                            ),
                            subtitleColor: _availabilityColor(
                              d.availableQuantity,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Redeem / Claim Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _redeemLoading
                            ? null
                            : () async {
                          if (!widget.isRedeem) {
                            // Claim flow (scan QR)
                            context.navigateToNextPage(
                              RewardScanQrCodePage(
                                redemptionId:
                                _details?.id ?? '',
                              ),
                            );
                            return;
                          }

                          // Redeem flow
                          if (_details == null ||
                              _balance == null) {
                            context.showErrorSnackBar(
                              'Unable to redeem at the moment. Please try again.',
                            );
                            return;
                          }

                          if (_details!
                              .availableQuantity <=
                              0) {
                            context.showErrorSnackBar(
                              'This reward is out of stock.',
                            );
                            return;
                          }

                          final userPts =
                              _balance?.totalBalance ?? 0;
                          if (userPts <
                              _details!.requiredPoints) {
                            context.showErrorSnackBar(
                              'Not enough points to redeem this reward.',
                            );
                            return;
                          }

                          final proceed =
                          await _showRedeemConfirmDialog(
                            context,
                          );
                          if (proceed != true) return;

                          setState(() =>
                          _redeemLoading = true);
                          try {
                            await _rewardModel
                                .rewardRedeem(
                              _details!.id,
                            );

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
                              context.showErrorSnackBar(
                                e.toString(),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(
                                    () => _redeemLoading =
                                false,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (!_canRedeem &&
                              widget.isRedeem)
                              ? Colors.grey
                              : Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _redeemLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          widget.isRedeem
                              ? 'Redeem'
                              : 'Scan to Claim',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Colors.grey[700], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: subtitleColor ?? Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool?> _showRedeemConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Image.asset(
                      AssetImageUtils.redeemConfirmIcon,
                      width: 84,
                      height: 84,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Are you sure to\nredeem this reward?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close (X)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
