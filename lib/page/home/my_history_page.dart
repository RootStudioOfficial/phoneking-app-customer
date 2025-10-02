import 'package:flutter/material.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';

class MyHistoryPage extends StatelessWidget {
  const MyHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final txns = <_Txn>[
      _Txn(title: 'Points Earned', desc: 'iPhone 14 screen repaired.', date: DateTime(2025, 9, 12), points: 240, type: TxnType.earn),
      _Txn(title: 'Rewards Exchanged', desc: 'iPhone 14 screen repaired.', date: DateTime(2025, 9, 12), points: -3000, type: TxnType.redeem),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Summary cards
          Row(
            children: const [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Spent',
                  value: '500,000 Ks',
                  bg: Color(0xFFED5B23),
                  bg2: Color(0xFF2450FF),
                  textColor: Colors.white,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _SummaryCard(
                  label: 'Points Earned',
                  value: '500,000 Ks',
                  bg: Color(0xFF1FB251),
                  bg2: Color(0xFF21C06A),
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          const Text(
            'Recent Transactions',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),

          // Transaction list
          ...txns.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TxnCard(txn: t),
            ),
          ),
        ],
      ),
    );
  }
}

// ======= Widgets =======

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color bg2;
  final Color textColor;

  const _SummaryCard({required this.label, required this.value, required this.bg, required this.bg2, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [bg, bg2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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

  _Txn({required this.title, required this.desc, required this.date, required this.points, required this.type});
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
        boxShadow: const [BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x0C000000))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading icon with asset
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: isEarn ? const Color(0xFFEAF8EE) : const Color(0xFFFEECEC), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Image.asset(isEarn ? AssetImageUtils.rewardIcon : AssetImageUtils.rewardIcon, width: 22, height: 22, color: color)),
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ),
                    Text(
                      '$sign ${txn.points.abs()} Pts',
                      style: TextStyle(color: color, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(txn.desc, style: const TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                Text(
                  _fmtDate(txn.date),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
