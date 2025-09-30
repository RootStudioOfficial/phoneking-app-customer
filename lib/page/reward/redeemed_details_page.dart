import 'package:flutter/material.dart';

class RedeemDetailsPage extends StatefulWidget {
  const RedeemDetailsPage({
    super.key,
    this.title = '20% off screen repair',
    this.category = 'Services',
    this.pointsRequired = 2000,
    this.userBalance = 12468,
    this.description =
        'Professional Screen replacement service Professional Screen replacement serviceProfessional Screen replacement serviceProfessional Screen replacement service',
  });

  final String title;
  final String category;
  final int pointsRequired;
  final int userBalance;
  final String description;

  @override
  State<RedeemDetailsPage> createState() => _RedeemDetailsPageState();
}

class _RedeemDetailsPageState extends State<RedeemDetailsPage> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final canRedeem = widget.userBalance >= widget.pointsRequired && !_processing;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reward Details', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Content
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // Banner
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: const [
                    // Swap with: Image.asset('assets/banner.png', fit: BoxFit.cover)
                    Placeholder(),
                    // subtle white separator at the bottom
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(height: 1, child: ColoredBox(color: Color(0xFFEAECEF))),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _chip(widget.category),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(widget.description, style: const TextStyle(color: Color(0xFF6B7280), height: 1.45)),
              ),
              const SizedBox(height: 16),

              // Points card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PointsCard(requiredPts: widget.pointsRequired, balancePts: widget.userBalance),
              ),
              const SizedBox(height: 12),

              // Category card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CategoryCard(category: widget.category),
              ),
            ],
          ),

          // Bottom sticky Redeem
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canRedeem ? _confirmRedeem : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6A00),
                      disabledBackgroundColor: const Color(0xFFED7F3A).withValues(alpha: .45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    child: _processing
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Redeem'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- Dialog flow -----
  Future<void> _confirmRedeem() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      builder: (_) => const _ConfirmDialog(),
    );
    if (ok != true) return;

    setState(() => _processing = true);

    // TODO: call your redeem API here
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _processing = false);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Redeemed successfully!')));

    // Optionally pop back:
    // Navigator.of(context).pop(true);
  }
}

// ===== Small UI bits =====

Widget _chip(String text) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(color: const Color(0xFFFFEEE5), borderRadius: BorderRadius.circular(18)),
  child: Text(
    text,
    style: const TextStyle(color: Color(0xFFFF6A00), fontWeight: FontWeight.w800, fontSize: 12),
  ),
);

class _PointsCard extends StatelessWidget {
  final int requiredPts;
  final int balancePts;

  const _PointsCard({required this.requiredPts, required this.balancePts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Points Required:',
                style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              const Icon(Icons.star, color: Color(0xFFFFC107)),
              const SizedBox(width: 6),
              Text(
                _fmt(requiredPts),
                style: const TextStyle(color: Color(0xFFFF6A00), fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE6E8F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Your Balance:',
                style: TextStyle(color: Color(0xFF98A2B3), fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${_fmt(balancePts)} points',
                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final left = s.length - i - 1;
      if (left > 0 && left % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.category_outlined, color: Color(0xFF6B7280)),
          const SizedBox(width: 10),
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const Spacer(),
          Text(
            category,
            style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ===== Confirmation Dialog =====

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close “x”
            Align(
              alignment: Alignment.topRight,
              child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(false)),
            ),
            const SizedBox(height: 4),
            // Illustration (swap with your asset)
            SizedBox(
              height: 90,
              width: 90,
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: const Placeholder()),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure to\nredeem this reward?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE6E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6A00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
