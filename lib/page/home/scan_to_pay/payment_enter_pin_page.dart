import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/data/vos/payment_success_vo/payment_success_vo.dart';
import 'package:phone_king_customer/page/home/scan_to_pay/payment_success_page.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
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

class _PaymentEnterPinPageState extends State<PaymentEnterPinPage> {
  final _pointModel = PhoneKingPointModelImpl();

  bool _submitting = false;
  String _pin = '';

  Future<void> _confirm() async {
    final l10n = LocalizationString.of(context);

    if (_pin.length != 6) {
      context.showErrorSnackBar(l10n.paymentEnterPinError);
      return;
    }
    if (_submitting) return;

    setState(() => _submitting = true);

    try {
      final res = await _pointModel.makePayment(widget.keyQR, _pin);

      if (!mounted) return;
      if (res.data == null) {
        throw Exception('Payment failed');
      }

      final PaymentSuccessVO data = res.data!;
      context.navigateToNextPage(
        PaymentSuccessPage(paymentData: data),
      );
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            l10n.paymentEnterPinTitle,
            style: _PinTextStyles.appBarTitle,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: _submitting ? null : const BackButton(color: Colors.black),
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
                      l10n.paymentEnterPinTitle,
                      style: _PinTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.paymentEnterPinSubtitle,
                      style: _PinTextStyles.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),

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
                            ),
                            child: Text(
                              l10n.commonCancel,
                              style: _PinTextStyles.buttonSecondary,
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
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              l10n.commonConfirm,
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

            // ===== Loading overlay =====
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
