import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phonekingcustomer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phonekingcustomer/data/vos/history_vo/history_summary_vo/history_summary_vo.dart';
import 'package:phonekingcustomer/data/vos/history_vo/history_vo.dart';
import 'package:phonekingcustomer/utils/extensions/dialog_extensions.dart';
import 'package:phonekingcustomer/utils/localization_strings.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _pointModel = PhoneKingPointModelImpl();

  bool _loading = false;
  String? _error;
  List<HistoryVO> _history = const [];
  HistorySummaryVO? _summary;

  DateTime? _fromDate;
  DateTime? _toDate;

  final _fromCtl = TextEditingController();
  final _toCtl = TextEditingController();

  String? _rangeError;

  @override
  void initState() {
    super.initState();
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
      if (_rangeError != null) context.showErrorSnackBar(_rangeError!);
      return;
    }

    setState(() {
        _loading = true;
        _error = null;
      });

    try {
      final resHistory =
      await _pointModel.getHistory(_apiDate(_fromDate!), _apiDate(_toDate!));
      final resSummary =
      await _pointModel.getSummary(_apiDate(_fromDate!), _apiDate(_toDate!));

      if (!mounted) return;
      setState(() {
        _history = resHistory.data ?? [];
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

  bool _validate() {
    final t = LocalizationString.of(context);
    _rangeError = null;

    if (_fromDate == null || _toDate == null) {
      _rangeError = t.activityErrorSelectBothDates;
      return false;
    }
    if (_fromDate!.isAfter(_toDate!)) {
      _rangeError = t.activityErrorStartAfterEnd;
      return false;
    }
    return true;
  }

  Future<void> _pickDateRange() async {
    final t = LocalizationString.of(context);
    final now = DateTime.now();
    final first = _fromDate ?? now.subtract(const Duration(days: 29));
    final last = _toDate ?? now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: DateTimeRange(start: first, end: last),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFED5B23),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _fromDate = DateTime(picked.start.year, picked.start.month, picked.start.day);
        _toDate = DateTime(picked.end.year, picked.end.month, picked.end.day);
        _fromCtl.text = _fmtDate(_fromDate!);
        _toCtl.text = _fmtDate(_toDate!);
      });
      await _fetchAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = LocalizationString.of(context);
    final txns = _history.map(_mapToTxn).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.activityTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date range picker card
            _DateRangeChip(
              fromText: _fromDate != null ? _fmtDate(_fromDate!) : '—',
              toText: _toDate != null ? _fmtDate(_toDate!) : '—',
              onTap: _pickDateRange,
              label: t.activityFilterByDate,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _SummaryCard(
                  label: t.activityPointsSpent,
                  value: _summary == null
                      ? '—'
                      : '${_fmtPoints(_summary!.pointSpend)} ${t.homePts}',
                  isEarn: false,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  label: t.activityPointsEarned,
                  value: _summary == null
                      ? '—'
                      : '${_fmtPoints(_summary!.pointEarned)} ${t.homePts}',
                  isEarn: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(t.activityRecentTransactions,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (txns.isEmpty && !_loading)
              Text(t.activityNoTransactions),
            ...txns.map((e) => _TxnCard(txn: e)),
          ],
        ),
      ),
    );
  }

  _Txn _mapToTxn(HistoryVO h) {
    final t = LocalizationString.of(context);
    final isEarn = h.totalPoints >= 0;
    DateTime date;
    try {
      date = DateTime.parse(h.txnDate);
    } catch (_) {
      date = DateTime.now();
    }
    return _Txn(
      title:
      isEarn ? t.activityTxnPointsEarned : t.activityTxnPointsSpent,
      desc: h.description,
      date: date,
      points: h.totalPoints,
      isEarn: isEarn,
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  static String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _fmtPoints(num n) =>
      n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',',
      );
}

// ===== UI helpers =====

class _DateRangeChip extends StatelessWidget {
  final String fromText;
  final String toText;
  final VoidCallback onTap;
  final String label;

  const _DateRangeChip({
    required this.fromText,
    required this.toText,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFED5B23).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Color(0xFFED5B23), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$fromText — $toText',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isEarn;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.isEarn,
  });

  static const Color _spentBg = Color(0xFFFFF5F5);
  static const Color _spentAccent = Color(0xFFB91C1C);
  static const Color _earnBg = Color(0xFFF0FDF4);
  static const Color _earnAccent = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    final bg = isEarn ? _earnBg : _spentBg;
    final accent = isEarn ? _earnAccent : _spentAccent;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Txn {
  final String title;
  final String desc;
  final DateTime date;
  final int points;
  final bool isEarn;

  _Txn({
    required this.title,
    required this.desc,
    required this.date,
    required this.points,
    required this.isEarn,
  });
}

class _TxnCard extends StatelessWidget {
  final _Txn txn;

  const _TxnCard({required this.txn});

  static const Color _spentAccent = Color(0xFFB91C1C);
  static const Color _earnAccent = Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    final t = LocalizationString.of(context);
    final isEarn = txn.isEarn;
    final accent = isEarn ? _earnAccent : _spentAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEarn ? Icons.add_rounded : Icons.remove_rounded,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  txn.desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${txn.isEarn ? '+' : '-'}${txn.points.abs()} ${t.homePts}',
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
