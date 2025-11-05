import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/data/vos/history_vo/history_summary_vo/history_summary_vo.dart';
import 'package:phone_king_customer/data/vos/history_vo/history_vo.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart'; // for context.showErrorSnackBar

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  State<MyHistoryPage> createState() => _MyHistoryPageState();
}

class _MyHistoryPageState extends State<MyHistoryPage> {
  final _pointModel = PhoneKingPointModelImpl();

  // API state
  bool _loading = false;
  String? _error;
  List<HistoryVO> _history = const [];
  HistorySummaryVO? _summary;

  // Date range state
  DateTime? _fromDate;
  DateTime? _toDate;

  // Text controllers to show selected dates
  final _fromCtl = TextEditingController();
  final _toCtl = TextEditingController();

  // Validation message
  String? _rangeError;

  @override
  void initState() {
    super.initState();
    // Default last 30 days
    final now = DateTime.now();
    _toDate = DateTime(now.year, now.month, now.day);
    _fromDate = _toDate!.subtract(const Duration(days: 29));
    _fromCtl.text = _fmtDate(_fromDate!);
    _toCtl.text = _fmtDate(_toDate!);

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  @override
  void dispose() {
    _fromCtl.dispose();
    _toCtl.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    if (!_validate()) {
      setState(() {
        _error = _rangeError;
      });
      if (_rangeError != null) context.showErrorSnackBar(_rangeError!);
      return;
    }

    final from = _apiDate(_fromDate!);
    final to = _apiDate(_toDate!);

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resHistory = await _pointModel.getHistory(from, to);
      final resSummary = await _pointModel.getSummary(from, to);

      if (!mounted) return;
      setState(() {
        _history = resHistory.data ?? const [];
        _summary = resSummary.data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() => _fetchAll();

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? _fromDate : _toDate) ?? now;
    final first = DateTime(now.year - 5, 1, 1);
    final last = DateTime(now.year + 1, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: isFrom ? 'Select start date' : 'Select end date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = DateTime(picked.year, picked.month, picked.day);
        _fromCtl.text = _fmtDate(_fromDate!);
      } else {
        _toDate = DateTime(picked.year, picked.month, picked.day);
        _toCtl.text = _fmtDate(_toDate!);
      }
    });
  }

  void _onApply() {
    _validate();
    if (_rangeError != null) {
      context.showErrorSnackBar(_rangeError ?? '');
      setState(() {}); // to show error state if needed
      return;
    }
    _fetchAll();
  }

  void _onClear() {
    setState(() {
      final now = DateTime.now();
      _toDate = DateTime(now.year, now.month, now.day);
      _fromDate = _toDate!.subtract(const Duration(days: 29));
      _fromCtl.text = _fmtDate(_fromDate!);
      _toCtl.text = _fmtDate(_toDate!);
      _rangeError = null;
    });
    _fetchAll();
  }

  bool _validate() {
    _rangeError = null;
    if (_fromDate == null || _toDate == null) {
      _rangeError = 'Please select both From and To dates.';
      return false;
    }
    if (_fromDate!.isAfter(_toDate!)) {
      _rangeError = 'Start date cannot be after end date.';
      return false;
    }
    return true;
  }

  // -------- format helpers --------
  static String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _apiDate(DateTime d) {
    // YYYY-MM-DD
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  static String _fmtPoints(num n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  // Map HistoryVO -> UI row data
  _Txn _mapToTxn(HistoryVO h) {
    final isEarn = (h.totalPoints) >= 0;
    final title = isEarn ? 'Points Earned' : 'Points Spent';
    return _Txn(
      title: title,
      desc: h.description,
      date: DateTime.parse(h.txnDate),
      points: h.totalPoints,
      type: isEarn ? TxnType.earn : TxnType.redeem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final txns = _history.map(_mapToTxn).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Summary cards (bind to HistorySummaryVO)
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Points Spent',
                    value: _summary == null
                        ? '—'
                        : '${_fmtPoints(_summary!.pointSpend)} pts',
                    bg: const Color(0xFFED5B23),
                    bg2: const Color(0xFF2450FF),
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SummaryCard(
                    label: 'Points Earned',
                    value: _summary == null
                        ? '—'
                        : '${_fmtPoints(_summary!.pointEarned)} pts',
                    bg: const Color(0xFF1FB251),
                    bg2: const Color(0xFF21C06A),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Date range filter
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'From',
                          controller: _fromCtl,
                          onTap: () => _pickDate(isFrom: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'To',
                          controller: _toCtl,
                          onTap: () => _pickDate(isFrom: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _loading ? null : _onApply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2450FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Apply'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _loading ? null : _onClear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF374151),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  if (_rangeError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _rangeError!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),

            if (_loading && _history.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            else if (_error != null && _history.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF9C2C2)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFB91C1C)),
                ),
              )
            else if (txns.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Text(
                  'No transactions found for the selected range.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              )
            else
              ...txns.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TxnCard(txn: t),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ======= Small date field widget =======

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: 'Select date',
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.date_range),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2450FF),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ======= UI components =======

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color bg2;
  final Color textColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.bg,
    required this.bg2,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg, bg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

enum TxnType { earn, redeem }

class _Txn {
  final String title;
  final String desc;
  final DateTime date;
  final int points; // negative for redemption
  final TxnType type;

  _Txn({
    required this.title,
    required this.desc,
    required this.date,
    required this.points,
    required this.type,
  });
}

class _TxnCard extends StatelessWidget {
  final _Txn txn;

  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isEarn = txn.points >= 0;
    final color = isEarn ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final sign = isEarn ? '+' : '−';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x0C000000),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading icon with asset
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEarn ? const Color(0xFFEAF8EE) : const Color(0xFFFEECEC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(
                isEarn
                    ? AssetImageUtils.rewardIcon
                    : AssetImageUtils.rewardIcon,
                width: 22,
                height: 22,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Amount
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        txn.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      '$sign ${_fmtPoints(txn.points.abs())} pts',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  txn.desc,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 8),
                Text(
                  _fmtDate(txn.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _fmtPoints(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
