import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_king_customer/data/vos/payment_success_vo/payment_success_vo.dart';
import 'package:phone_king_customer/page/home/scan_to_pay/payment_success_page.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';

import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';

class PaymentEnterPinPage extends StatefulWidget {
  const PaymentEnterPinPage({super.key, required this.keyQR});

  final String keyQR;

  @override
  State<PaymentEnterPinPage> createState() => _PaymentEnterPinPageState();
}

class _PaymentEnterPinPageState extends State<PaymentEnterPinPage>
    with SingleTickerProviderStateMixin {
  final _nodes = List.generate(6, (_) => FocusNode());
  final _ctls = List.generate(6, (_) => TextEditingController());

  final _pointModel = PhoneKingPointModelImpl();

  // UI state
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nodes.first.requestFocus(),
    );
  }

  @override
  void dispose() {
    for (final c in _ctls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _pin => _ctls.map((e) => e.text).join();

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

    return WillPopScope(
      onWillPop: () async => !_submitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Payment Details',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Please enter your pin to confirm the transaction',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (i) => _PinBox(
                            controller: _ctls[i],
                            focusNode: _nodes[i],
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 5) {
                                _nodes[i + 1].requestFocus();
                              }
                              setState(() {});
                            },
                            onBackspace: () {
                              if (_ctls[i].text.isEmpty && i > 0) {
                                _nodes[i - 1].requestFocus();
                                _ctls[i - 1].clear();
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
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

// A single PIN box (one character)
class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Focus(
        focusNode: focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          obscureText: true,
          obscuringCharacter: '•',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
