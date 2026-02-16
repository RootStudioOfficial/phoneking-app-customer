import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import 'package:phonekingcustomer/data/model/reward/phone_king_reward_model_impl.dart';
import 'package:phonekingcustomer/page/reward/reward_success_page.dart';
import 'package:phonekingcustomer/utils/extensions/dialog_extensions.dart';
import 'package:phonekingcustomer/utils/extensions/navigation_extensions.dart';
import 'package:phonekingcustomer/utils/localization_strings.dart';

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
  final _rewardModel = PhoneKingRewardModelImpl();

  bool _submitting = false;
  String _pin = '';

  Future<void> _confirm() async {
    final l10n = LocalizationString.of(context);

    if (_pin.length != 6) {
      context.showErrorSnackBar(l10n.rewardPinInvalid);
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

      context.showSuccessSnackBar(l10n.rewardPinSuccess);

      if (res.data != null) {
        context.navigateToNextPage(
          RewardSuccessPage(rewardData: res.data!),
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);
    const orange = Color(0xFFE85B2A);

    return WillPopScope(
      onWillPop: () async => !_submitting,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            l10n.rewardPinTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: AbsorbPointer(
                absorbing: _submitting,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.rewardPinEnterTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.rewardPinEnterDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 22),

                    // PIN input
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
                        inputFormatters:  [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        obscureText: true,
                        showCursor: true,
                        closeKeyboardWhenCompleted: true,
                        onChanged: (pin) => _pin = pin,
                        onCompleted: (pin) => _pin = pin,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                            _submitting ? null : () => context.navigateBack(),
                            style: OutlinedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                  color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: Colors.black,
                            ),
                            child: Text(
                              l10n.commonCancel,
                              style:
                              const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _confirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _submitting
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              l10n.commonConfirm,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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
