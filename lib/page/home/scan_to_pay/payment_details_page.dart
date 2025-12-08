import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/vos/scan_payment_vo/scan_payment_vo.dart';
import 'package:phone_king_customer/page/home/scan_to_pay/payment_enter_pin_page.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';

// ========== Typography helper ==========

class _PaymentTextStyles {
  static const appBarTitle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const storeName = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const storeSubtitle = TextStyle(
    fontSize: 13,
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  );

  static const detailLabel = TextStyle(
    fontSize: 14,
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  );

  static const detailValue = TextStyle(
    fontSize: 15,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );

  static const detailValueStrong = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const errorText = TextStyle(
    color: Color(0xFFB00020),
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}

class PaymentDetailsPage extends StatefulWidget {
  const PaymentDetailsPage({super.key, required this.keyQR});

  final String keyQR;

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final _pointModel = PhoneKingPointModelImpl();

  bool _loading = true;
  String? _error;
  ScanPaymentVO? _data; // <-- Strong Typed

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
      final res = await _pointModel.scanPaymentQrInfo(widget.keyQR);

      if (!mounted) return;
      if (res.data == null) throw Exception("Empty response");

      _data = res.data as ScanPaymentVO;
    } catch (e) {
      _error = e.toString();
      if (mounted) context.showErrorSnackBar(_error!);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    final body = _loading
        ? const _LoadingBody()
        : _error != null
        ? _ErrorBody(message: _error!, onRetry: _load)
        : _SuccessBody(
            data: _data!,
            onProceed: () => _proceedToPayment(context),
            onRefresh: _load,
          );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.paymentDetailsPaymentDetails,
          style: _PaymentTextStyles.appBarTitle,
        ),
      ),
      body: body,
    );
  }

  void _proceedToPayment(BuildContext context) {
    context.navigateToNextPage(PaymentEnterPinPage(keyQR: widget.keyQR));
  }
}

// =================== Loading & Error ===================

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 36,
        width: 36,
        child: CircularProgressIndicator(strokeWidth: 2.6),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCACA)),
            ),
            child: Text(message, style: _PaymentTextStyles.errorText),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.data,
    required this.onProceed,
    required this.onRefresh,
  });

  final ScanPaymentVO data;
  final VoidCallback onProceed;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    final balanceAfter = data.currentBalance + data.pointAmount;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ---- Store Header ----
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.processByName,
                                      style: _PaymentTextStyles.storeName,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Invoice #${data.invoiceNo}",
                                      style: _PaymentTextStyles.storeSubtitle,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 1, color: Colors.grey[200]),

                        // ---- Payment Details ----
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildRow(
                                l10n.paymentDetailsInvoiceNo,
                                data.invoiceNo,
                              ),
                              const SizedBox(height: 16),
                              _buildRow(
                                l10n.paymentDetailsPointsToUse,
                                "-${data.pointAmount}",
                                color: Colors.deepOrange,
                              ),
                              const SizedBox(height: 16),
                              _buildRow(
                                l10n.paymentDetailsCurrentBalance,
                                _format(data.currentBalance),
                              ),
                              const SizedBox(height: 16),
                              _buildRow(
                                l10n.paymentDetailsBalanceAfter,
                                _format(balanceAfter),
                                strong: true,
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
        ),

        // ---- Bottom Buttons ----
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Proceed to Payment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color color = Colors.black,
    bool strong = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _PaymentTextStyles.detailLabel),
        Text(
          value,
          style:
              (strong
                      ? _PaymentTextStyles.detailValueStrong
                      : _PaymentTextStyles.detailValue)
                  .copyWith(color: color),
        ),
      ],
    );
  }

  String _format(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
