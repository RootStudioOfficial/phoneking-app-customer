import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_king_customer/data/vos/payment_success_vo/payment_success_vo.dart';
import 'package:phone_king_customer/page/home/scan_to_pay/payment_success_page.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';

import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';
import 'package:pinput/pinput.dart';

class PaymentEnterPinPage extends StatefulWidget {
  const PaymentEnterPinPage({super.key, required this.keyQR});

  final String keyQR;

  @override
  State<PaymentEnterPinPage> createState() => _PaymentEnterPinPageState();
}

// ========= Typography helper =========

class _PinTextStyles {
  static const appBarTitle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 18,
    color: Colors.black,
  );

  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Color(0xFF111827),
  );

  static const subtitle = TextStyle(
    fontSize: 13,
    color: Color(0xFF9E9E9E),
    fontWeight: FontWeight.w400,
  );

  static const buttonSecondary = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const buttonPrimary = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

class _PaymentEnterPinPageState extends State<PaymentEnterPinPage>
    with SingleTickerProviderStateMixin {
  final _pointModel = PhoneKingPointModelImpl();

  // UI state
  bool _submitting = false;
  String _pin = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_pin.length != 6) {
      context.showErrorSnackBar('Please enter your 6 digit PIN');
      return;
    }
    if (_submitting) return;

    setState(() => _submitting = true);
    try {
      final res = await _pointModel.makePayment(widget.keyQR, _pin);

      if (!mounted) return;

      if (res.data == null) {
        throw Exception('Payment failed: empty response.');
      }

      final PaymentSuccessVO data = res.data!;
      context.navigateToNextPage(PaymentSuccessPage(paymentData: data));
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
    final l10n = LocalizationString.of(context);

    return WillPopScope(
      onWillPop: () async => !_submitting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.paymentDetailsPaymentDetails, // "Payment Details"
            style: _PinTextStyles.appBarTitle,
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
                        'Enter Your 6 digit Pin',
                        style: _PinTextStyles.title,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Please enter your pin to confirm the transaction',
                        style: _PinTextStyles.subtitle,
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
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        closeKeyboardWhenCompleted: true,
                        obscureText: true,
                        onCompleted: (pin) {
                          if (mounted) {
                            setState(() {
                              _pin = pin;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
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
                            onPressed: _submitting
                                ? null
                                : () => context.navigateBack(),
                            child: const Text(
                              'Cancel',
                              style: _PinTextStyles.buttonSecondary,
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
                              style: _PinTextStyles.buttonPrimary,
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

