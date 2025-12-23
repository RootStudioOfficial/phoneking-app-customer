import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/point/phone_king_point_model_impl.dart';
import 'package:phone_king_customer/data/vos/history_vo/history_summary_vo/history_summary_vo.dart';
import 'package:phone_king_customer/data/vos/history_vo/history_vo.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';

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

    setState(() => _loading = true);

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

  @override
  Widget build(BuildContext context) {
    final t = LocalizationString.of(context);
    final txns = _history.map(_mapToTxn).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.activityTitle),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _SummaryCard(
                  label: t.activityPointsSpent,
                  value: _summary == null
                      ? '—'
                      : '${_fmtPoints(_summary!.pointSpend)} ${t.homePts}',
                  color: const Color(0xFFEF4444),
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  label: t.activityPointsEarned,
                  value: _summary == null
                      ? '—'
                      : '${_fmtPoints(_summary!.pointEarned)} ${t.homePts}',
                  color: const Color(0xFF16A34A),
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
    return _Txn(
      title:
      isEarn ? t.activityTxnPointsEarned : t.activityTxnPointsSpent,
      desc: h.description,
      date: DateTime.parse(h.txnDate),
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
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

  @override
  Widget build(BuildContext context) {
    final t = LocalizationString.of(context);
    final color =
    txn.isEarn ? const Color(0xFF16A34A) : const Color(0xFFEF4444);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Image.asset(
          AssetImageUtils.rewardIcon,
          color: color,
        ),
        title: Text(txn.title),
        subtitle: Text(txn.desc),
        trailing: Text(
          '${txn.isEarn ? '+' : '-'}${txn.points.abs()} ${t.homePts}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
