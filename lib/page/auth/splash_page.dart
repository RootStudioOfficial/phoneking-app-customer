import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  /// Where to go when splash finishes or "Skip" is tapped.
  final VoidCallback onFinish;

  /// Seconds to show before auto-finish.
  final int seconds;

  const SplashPage({
    super.key,
    required this.onFinish,
    this.seconds = 3,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late int _left = widget.seconds;
  Timer? _timer;

  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        widget.onFinish();
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  void _skip() {
    _timer?.cancel();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.0,
                  colors: [
                    Color(0xFFDA6B1F), // orange glow
                    Color(0xFF0F0F0F), // deep black
                  ],
                  stops: [0.0, 0.55],
                ),
              ),
            ),
          ),

          // Center logo with scale + fade
          Center(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _ac, curve: Curves.easeOut),
              child: ScaleTransition(
                scale: CurvedAnimation(
                    parent: _ac, curve: Curves.easeOutBack),
                child: SizedBox(
                  width: 170,
                  height: 170,
                  // Replace with Image.asset('assets/logo_plus.png', fit: BoxFit.contain)
                  child: const Placeholder(),
                ),
              ),
            ),
          ),

          // Skip pill (top-right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: GestureDetector(
                  onTap: _skip,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      "Skip in $_left${_left == 1 ? 's' : 's'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom brand
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'SF Pro', // optional
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                    children: [
                      TextSpan(
                        text: "PhoneKing",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: "Plus",
                        style: TextStyle(
                          color: Color(0xFFFE6A00), // orange
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
