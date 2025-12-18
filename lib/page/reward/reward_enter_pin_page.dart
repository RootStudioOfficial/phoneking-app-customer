import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_king_customer/page/reward/reward_success_page.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';

import 'package:phone_king_customer/data/model/reward/phone_king_reward_model_impl.dart';
import 'package:pinput/pinput.dart';

class RewardEnterPinPage extends StatefulWidget {
  const RewardEnterPinPage({
    super.key,
    required this.paymentKey,
    required this.redemptionId,
  });

  final String paymentKey;
  final String redemptionId;

  @override
  State<RewardEnterPinPage> createState() => _RewardEnterPinPageState();
}

class _RewardEnterPinPageState extends State<RewardEnterPinPage>
    with SingleTickerProviderStateMixin {
  // API model
  final _rewardModel = PhoneKingRewardModelImpl();

  // UI state
  bool _submitting = false;
  String _pin = "";

  Future<void> _confirm() async {
    if (_pin.length != 6) {
      context.showErrorSnackBar('Please enter your 6 digit PIN');
      return;
    }
    if (_submitting) return;

    setState(() => _submitting = true);
    try {
      final res = await _rewardModel.claimReward(
        widget.paymentKey,
        _pin,
        widget.redemptionId,
      );

      if (!mounted) return;

      context.showSuccessSnackBar('Reward claimed successfully');
      if (res.data != null) {
        context.navigateToNextPage(
          RewardSuccessPage(rewardData: res.data!),
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFE85B2A);

    return WillPopScope(
      // Block system back while submitting
      onWillPop: () async => !_submitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Redeemed Confirm',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ==== Main content ====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: AbsorbPointer(
                absorbing: _submitting, // Block taps while loading
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Enter Your 6 digit PIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Please enter your PIN to confirm the transaction',
                        style: TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // PIN boxes container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Pinput(
                        length: 6,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        closeKeyboardWhenCompleted: true,
                        obscureText: true,
                        onChanged: (pin) {
                          _pin = pin;
                        },
                        onCompleted: (pin) {
                          _pin = pin;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side:
                              const BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: _submitting
                                ? null
                                : () => context.navigateBack(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _submitting ? null : _confirm,
                            child: _submitting
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Confirm',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==== Loading overlay ====
            if (_submitting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: const Center(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
