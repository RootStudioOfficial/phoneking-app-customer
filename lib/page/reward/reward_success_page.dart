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
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Success Icon
                  Image.asset(
                    AssetImageUtils.rewardSuccessfulIcon,
                    width: 200,
                    height: 200,
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

                  const SizedBox(height: 32),

                  // Reward Preview Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Padding(
                          padding: const EdgeInsets.all(16),
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
                                    child: Image.network(
                                      rewardData.imageUrl,
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
                                          rewardData.rewardName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          rewardData.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
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
                                value: rewardData.redeemDate,
                              ),

                              const SizedBox(height: 16),

                              // Claim Date
                              _buildInfoRow(
                                label: 'Claim Date',
                                value: rewardData.collectedDate,
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
                  context.navigateToNextPageWithRemoveUntil(IndexPage());
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
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
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
