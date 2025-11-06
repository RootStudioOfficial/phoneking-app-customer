import 'package:flutter/material.dart';
import 'package:phone_king_customer/page/home/scan_to_pay/payment_enter_pin_page.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';

import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';

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

  dynamic _data;

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

      _data = res.data; // ScanPaymentVO
      if (_data == null) {
        throw Exception('Invalid QR or empty response.');
      }
    } catch (e) {
      _error = e.toString();
      if (mounted) context.showErrorSnackBar(_error!);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // --- Safe getters mapping (adjust keys to your actual ScanPaymentVO fields) ---
  String get storeName {
    // Prefer your real fields here:
    // return _data.store?.name ?? _data.merchantName ?? '—';
    try {
      return (_data.store?.name as String?) ??
          (_data.merchantName as String?) ??
          '—';
    } catch (_) {
      return '—';
    }
  }

  String get transactionId {
    try {
      return (_data.transactionId as String?) ??
          (_data.txnId as String?) ??
          '—';
    } catch (_) {
      return '—';
    }
  }

  String get invoiceNo {
    try {
      return (_data.invoiceNo as String?) ?? (_data.invoice as String?) ?? '—';
    } catch (_) {
      return '—';
    }
  }

  int get pointsToUse {
    // Many systems return “points to spend” as positive; we show negative.
    try {
      final raw =
          (_data.pointsToUse as num?) ?? (_data.spendPoints as num?) ?? 0;
      return -raw.toInt();
    } catch (_) {
      return 0;
    }
  }

  int get currentBalance {
    try {
      final b = (_data.currentBalance as num?) ?? 0;
      return b.toInt();
    } catch (_) {
      return 0;
    }
  }

  int get balanceAfter {
    // If API already returns a final/remaining balance, prefer that:
    try {
      final provided = (_data.balanceAfter as num?);
      if (provided != null) return provided.toInt();
    } catch (_) {}
    // Otherwise compute: current + pointsToUse (pointsToUse is negative in UI)
    return currentBalance + pointsToUse;
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const _LoadingBody()
        : _error != null
        ? _ErrorBody(message: _error!, onRetry: _load)
        : _SuccessBody(
            storeName: storeName,
            transactionId: transactionId,
            invoiceNo: invoiceNo,
            pointsToUse: pointsToUse,
            currentBalance: currentBalance,
            balanceAfter: balanceAfter,
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
        title: const Text(
          'Payment Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: body,
    );
  }

  void _proceedToPayment(BuildContext context) {
    context.navigateToNextPage(PaymentEnterPinPage(keyQR: widget.keyQR));
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({
    required this.storeName,
    required this.transactionId,
    required this.invoiceNo,
    required this.pointsToUse,
    required this.currentBalance,
    required this.balanceAfter,
    required this.onProceed,
    required this.onRefresh,
  });

  final String storeName;
  final String transactionId;
  final String invoiceNo;
  final int pointsToUse;
  final int currentBalance;
  final int balanceAfter;

  final VoidCallback onProceed;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
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
                  // Payment Details Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.08),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Store Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Store Icon (could be replaced with logo if available)
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
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Store Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Transaction #$transactionId',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(height: 1, color: Colors.grey[200]),

                        // Payment Details
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                label: 'Invoice No',
                                value: invoiceNo,
                                valueColor: Colors.black,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: 'Points to Use',
                                value: pointsToUse.toString(),
                                // already negative
                                valueColor: Colors.deepOrange,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: 'Current Balance',
                                value: _formatNumber(currentBalance),
                                valueColor: Colors.black,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: 'Balance After',
                                value: _formatNumber(balanceAfter),
                                valueColor: Colors.black,
                                valueWeight: FontWeight.w600,
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

        // Bottom Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Proceed to Payment Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Proceed to Payment',
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
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color valueColor,
    FontWeight? valueWeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: valueWeight ?? FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
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
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB00020)),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
