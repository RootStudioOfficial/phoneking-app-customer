import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_claim_success_vo/reward_claim_success_vo.dart';
import 'package:phone_king_customer/page/index_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';

class RewardSuccessPage extends StatelessWidget {
  const RewardSuccessPage({super.key, required this.rewardData});

  final RewardClaimSuccessVO rewardData;

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    final redeemDate = DateTime.now();
    final collectedDate = DateTime.now();
    final rewardName = rewardData.rewardName;
    final description = rewardData.description;
    final imageUrl = rewardData.imageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.navigateBack(),
        ),
        title: Text(
          l10n.rewardSuccessTitle,
          style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Success Icon
                    Image.asset(AssetImageUtils.rewardSuccessfulIcon, width: 180, height: 180),

                    const SizedBox(height: 24),

                    Text(
                      l10n.rewardSuccessCompleted,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      l10n.rewardSuccessHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 32),

                    // Preview Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(l10n.rewardSuccessPreview, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),

                          Divider(height: 1, color: Colors.grey[200]),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: imageUrl.isEmpty
                                          ? _imagePlaceholder()
                                          : Image.network(
                                              imageUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rewardName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          if (description.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(description, style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey[600])),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                _infoRow(l10n.rewardSuccessRedeemedAt, DateFormat('yyyy-MM-dd hh:mm:ss a').format(redeemDate)),
                                const SizedBox(height: 16),
                                _infoRow(l10n.rewardSuccessClaimDate, DateFormat('yyyy-MM-dd hh:mm:ss a').format(collectedDate)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.navigateToNextPageWithRemoveUntil(const IndexPage(desireIndex: 1, desireRewardIndex: 1));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.rewardSuccessGoHome,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final safe = value.isEmpty ? '-' : value;
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        ),
        Expanded(
          flex: 6,
          child: Text(
            safe,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
    );
  }
}
