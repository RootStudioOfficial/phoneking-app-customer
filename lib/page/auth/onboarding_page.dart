// lib/onboarding_flow.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum _Sheet { none, phone, pin, personal }

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
  late final Animation<double> _scale = CurvedAnimation(parent: _ac, curve: Curves.easeOutBack);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, .25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

  _Sheet _sheet = _Sheet.none;

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  // --- Navigation between sheets with the same animation ---
  void _openPhone() {
    setState(() => _sheet = _Sheet.phone);
    _ac.forward(from: 0);
  }

  Future<void> _gotoPin() async {
    await _ac.reverse();
    if (!mounted) return;
    setState(() => _sheet = _Sheet.pin);
    _ac.forward(from: 0);
  }

  Future<void> _gotoPersonal() async {
    await _ac.reverse();
    if (!mounted) return;
    setState(() => _sheet = _Sheet.personal);
    _ac.forward(from: 0);
  }

  Future<void> _finishFlow() async {
    await _ac.reverse();
    if (!mounted) return;
    setState(() => _sheet = _Sheet.none);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All set! Welcome to PhoneKing.")));
  }

  Future<void> _closeAny() async {
    await _ac.reverse();
    if (!mounted) return;
    setState(() => _sheet = _Sheet.none);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C34FF),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Gradient background
            Positioned.fill(
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0C1B4D), Color(0xFF0C34FF)]),
                ),
              ),
            ),

            // Content
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Expanded(child: _PlanetCanvas()),

                  // Marketing card + CTA
                  _BottomCard(
                    title: "PhoneKing",
                    subtitle: "Your gateway to exclusive rewards,\namazing deals and premium services",
                    buttonText: "Get Started",
                    onPressed: _openPhone,
                  ),
                ],
              ),
            ),

            // Scrim + animated sheet
            if (_sheet != _Sheet.none) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeAny,
                  child: AnimatedBuilder(
                    animation: _ac,
                    builder: (_, __) => ColoredBox(color: Colors.black.withValues(alpha: .35 * _ac.value)),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _slide,
                  child: ScaleTransition(
                    scale: _scale,
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: switch (_sheet) {
                        _Sheet.phone => _PhoneFormCard(onConfirm: _gotoPin),
                        _Sheet.pin => _PinFormCard(onConfirm: _gotoPersonal),
                        _Sheet.personal => _PersonalInfoFormCard(onConfirm: _finishFlow),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Decorative background canvas (replace Placeholders with Image.asset)
// ---------------------------------------------------------------------
class _PlanetCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final r1 = w * 0.62, r2 = w * 0.46, rc = w * 0.28;

        return Stack(
          alignment: Alignment.center,
          children: [
            _orbit(r1, .35),
            _orbit(r2, .45),
            _orbit(rc, .25),
            Container(
              width: rc * .45,
              height: rc * .45,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text(
                  "K",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 36, color: Color(0xFF0C34FF)),
                ),
              ),
            ),
            // Floating placeholders — swap for Image.asset(...)
            _badge(r1 / 2, -20),
            _badge(r1 / 2, 25),
            _badge(r1 / 2, 155),
            _badge(r2 / 2, -60),
            _badge(r2 / 2, 10),
            _badge(r2 / 2, 85),
            _badge(r2 / 2, 210),
          ],
        );
      },
    );
  }

  Widget _orbit(double d, double o) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: o), width: 2),
    ),
  );

  Widget _badge(double radius, double deg) {
    final rad = deg * math.pi / 180;
    return Transform.translate(
      offset: Offset(radius * math.cos(rad), radius * math.sin(rad)),
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        padding: const EdgeInsets.all(8),
        child: const Placeholder(), // <-- replace with Image.asset(...)
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Step 1: Phone sheet
// ---------------------------------------------------------------------
class _PhoneFormCard extends StatefulWidget {
  final VoidCallback onConfirm;

  const _PhoneFormCard({required this.onConfirm});

  @override
  State<_PhoneFormCard> createState() => _PhoneFormCardState();
}

class _PhoneFormCardState extends State<_PhoneFormCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _grabber(),
            const Text("Unlock Amazing Benefits", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),

            _label("Phone Number"),
            const SizedBox(height: 8),

            Row(
              children: [
                // Country code
                Container(
                  width: 74,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FB),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                    border: Border.all(color: const Color(0xFFE6E8F0)),
                  ),
                  child: const Text("+95", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: "type your phone number",
                        filled: true,
                        fillColor: Color(0xFFF7F8FB),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE6E8F0)),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE6E8F0)),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1133FF), width: 1.4),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: add real validation before proceeding
                  widget.onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1133FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Step 2: Create PIN sheet
// ---------------------------------------------------------------------
class _PinFormCard extends StatefulWidget {
  final VoidCallback onConfirm;

  const _PinFormCard({required this.onConfirm});

  @override
  State<_PinFormCard> createState() => _PinFormCardState();
}

class _PinFormCardState extends State<_PinFormCard> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  bool _ob1 = true, _ob2 = true;

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
  }

  String? _validatePin(String v) {
    if (v.length != 6 || int.tryParse(v) == null) return "PIN must be 6 digits";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _grabber(),
            const Text("Create Your Safety Pin", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),

            _label("PIN Number"),
            const SizedBox(height: 8),
            _pinField(
              controller: _pin1,
              obscure: _ob1,
              onToggle: () {
                setState(() => _ob1 = !_ob1);
              },
            ),

            const SizedBox(height: 18),
            _label("Confirm PIN Number"),
            const SizedBox(height: 8),
            _pinField(
              controller: _pin2,
              obscure: _ob2,
              onToggle: () {
                setState(() => _ob2 = !_ob2);
              },
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final err1 = _validatePin(_pin1.text);
                  final err2 = _validatePin(_pin2.text);
                  if (err1 != null || err2 != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err1 ?? err2!)));
                    return;
                  }
                  if (_pin1.text != _pin2.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PINs do not match")));
                    return;
                  }
                  widget.onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1133FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Create", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pinField({required TextEditingController controller, required bool obscure, required VoidCallback onToggle}) {
    return SizedBox(
      height: 52,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: TextInputType.number,
        maxLength: 6,
        buildCounter: (_, {int? currentLength, bool? isFocused, int? maxLength}) => const SizedBox(),
        decoration: InputDecoration(
          hintText: "must be 6 digits",
          filled: true,
          fillColor: const Color(0xFFF7F8FB),
          suffixIcon: IconButton(onPressed: onToggle, icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE6E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE6E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF1133FF), width: 1.4),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Step 3: Personal Info sheet
// ---------------------------------------------------------------------
class _PersonalInfoFormCard extends StatefulWidget {
  final VoidCallback onConfirm;

  const _PersonalInfoFormCard({required this.onConfirm});

  @override
  State<_PersonalInfoFormCard> createState() => _PersonalInfoFormCardState();
}

class _PersonalInfoFormCardState extends State<_PersonalInfoFormCard> {
  final _nameCtrl = TextEditingController();
  String? _day, _month, _year;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _grabber(),
            const Text("Fill Your Personal Info", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),

            _label("Your Name"),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: "Enter Your Name",
                filled: true,
                fillColor: Color(0xFFF7F8FB),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE6E8F0)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE6E8F0)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1133FF), width: 1.4),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),

            const SizedBox(height: 18),
            _label("Your Birthday"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _birthdayDropdown(1, 31, _day, (v) => setState(() => _day = v))),
                const SizedBox(width: 8),
                Expanded(child: _birthdayDropdown(1, 12, _month, (v) => setState(() => _month = v))),
                const SizedBox(width: 8),
                Expanded(child: _birthdayDropdown(1960, DateTime.now().year, _year, (v) => setState(() => _year = v))),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameCtrl.text.trim().isEmpty || _day == null || _month == null || _year == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                    return;
                  }
                  widget.onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1133FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _birthdayDropdown(int start, int end, String? value, ValueChanged<String?> onChanged) {
    final items = List.generate(end - start + 1, (i) => (start + i).toString());
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Color(0xFFF7F8FB),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE6E8F0)),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE6E8F0)),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1133FF), width: 1.4),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      hint: const Text("-"),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------
// Shared tiny widgets
// ---------------------------------------------------------------------
Widget _label(String t) => Align(
  alignment: Alignment.centerLeft,
  child: Text(t, style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
);

Widget _grabber() => Container(
  width: 56,
  height: 5,
  margin: const EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(color: const Color(0xFFE6E8F0), borderRadius: BorderRadius.circular(12)),
);

// Marketing bottom card
class _BottomCard extends StatelessWidget {
  final String title, subtitle, buttonText;
  final VoidCallback onPressed;

  const _BottomCard({required this.title, required this.subtitle, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: const Color(0xFF0C34FF), borderRadius: BorderRadius.circular(6)),
                child: const Center(
                  child: Text(
                    "K",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0D1B2A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF384053)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C34FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
