import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_claim_success_vo/reward_claim_success_vo.dart';
import 'package:phone_king_customer/page/index_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';

class RewardSuccessPage extends StatelessWidget {
  final RewardClaimSuccessVO rewardData;

  const RewardSuccessPage({super.key, required this.rewardData});

  @override
  Widget build(BuildContext context) {
    final redeemDate = rewardData.redeemDate;
    final collectedDate = rewardData.collectedDate;
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
        title: const Text(
          'Reward Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
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
                    Image.asset(
                      AssetImageUtils.rewardSuccessfulIcon,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Reward Claimed Successfully.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Show this reward to the staff or follow the store instructions to enjoy your benefits.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Reward Preview Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Header
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Reward Preview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // Divider
                          Divider(height: 1, color: Colors.grey[200]),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Reward Info Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Reward Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: imageUrl.isEmpty
                                          ? Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image,
                                                color: Colors.grey[400],
                                                size: 40,
                                              ),
                                            )
                                          : Image.network(
                                              imageUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      width: 100,
                                                      height: 100,
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                        Icons.image,
                                                        color: Colors.grey[400],
                                                        size: 40,
                                                      ),
                                                    );
                                                  },
                                            ),
                                    ),

                                    const SizedBox(width: 16),

                                    // Reward Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rewardName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (description.isNotEmpty)
                                            Text(
                                              description,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                height: 1.4,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Redeemed at
                                _buildInfoRow(
                                  label: 'Redeemed at',
                                  value: redeemDate,
                                ),

                                const SizedBox(height: 16),

                                // Claim Date
                                _buildInfoRow(
                                  label: 'Claim Date',
                                  value: collectedDate,
                                ),
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

            // Go Back Home Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Go back to Rewards tab → Redeemed list
                    context.navigateToNextPageWithRemoveUntil(
                      const IndexPage(desireIndex: 1, desireRewardIndex: 1),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go Back Home',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    final safeValue = value.isEmpty ? '-' : value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Text(
            safeValue,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
