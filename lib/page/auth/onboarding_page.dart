import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/vos/login_vo/login_vo.dart';
import 'package:phone_king_customer/page/index_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';

import 'package:phone_king_customer/data/model/auth/phone_king_auth_model.dart';
import 'package:phone_king_customer/data/model/auth/phone_king_auth_model_impl.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

enum _Sheet { none, phone, otp, pin, personal, login }

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final Animation<double> _scale = CurvedAnimation(
    parent: _ac,
    curve: Curves.easeOutBack,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, .25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

  _Sheet _sheet = _Sheet.none;

  bool _busy = false;
  String? _phone;
  String? _pin;

  final PhoneKingAuthModel _auth = PhoneKingAuthModelImpl();

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _openPhone() {
    setState(() => _sheet = _Sheet.phone);
    _ac.forward(from: 0);
  }

  void _openLogin() {
    setState(() => _sheet = _Sheet.login);
    _ac.forward(from: 0);
  }

  Future<void> _gotoOtp() async {
    await _ac.reverse();
    if (!mounted) return;
    setState(() => _sheet = _Sheet.otp);
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
    context.navigateToNextPage(const IndexPage());
  }

  Future<void> _closeAny() async {
    await _ac.reverse();
    if (!mounted) return;
    setState(() => _sheet = _Sheet.none);
  }

  void _setBusy(bool v) {
    if (!mounted) return;
    setState(() => _busy = v);
  }

  void _snack(String msg, {bool isError = false}) {
    if (isError) {
      context.showErrorSnackBar(msg);
    } else {
      context.showSuccessSnackBar(msg);
    }
  }

  Future<void> _handleSendOtp(String fullPhone) async {
    _setBusy(true);
    try {
      await _auth.sendRegisterVerification(phoneNumber: fullPhone);
      _phone = fullPhone;
      _snack('OTP sent to $fullPhone');
      await _gotoOtp();
    } catch (e) {
      _snack(e.toString(), isError: true);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _handleVerifyOtp(String otp) async {
    if (_phone == null) {
      _snack('No phone found, please try again.', isError: true);
      return;
    }
    _setBusy(true);
    try {
      await _auth.confirmRegisterVerification(phoneNumber: _phone!, otp: otp);
      _snack('OTP verified');
      await _gotoPin();
    } catch (e) {
      _snack(e.toString(), isError: true);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _handleSetPin(String pin) async {
    _pin = pin;
    await _gotoPersonal();
  }

  Future<void> _handleRegister({
    required String name,
    required String day,
    required String month,
    required String year,
  }) async {
    if (_phone == null || _pin == null) {
      _snack('Something went wrong. Please try again.', isError: true);
      return;
    }
    final birthday =
        '${year.padLeft(4, '0')}-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}';

    _setBusy(true);
    try {
      final BaseResponse<LoginVO> res = await _auth.register(
        displayName: name,
        password: _pin!,
        phoneNumber: _phone!,
        birthday: birthday,
      );
      if (res.data != null) {
        _snack('Registration successful');
        await _finishFlow();
      } else {
        _snack(res.message, isError: true);
      }

      await _finishFlow();
    } catch (e) {
      _snack(e.toString(), isError: true);
    } finally {
      _setBusy(false);
    }
  }

  // ---- Login flow handler (🔗 API wired) ----
  Future<void> _handleLogin(String fullPhone, String password) async {
    _setBusy(true);
    try {
      final loginRes = await _auth.login(
        username: fullPhone,
        password: password,
      );
      if (loginRes.data != null) {
        _snack('Login success');
        await _finishFlow();
      } else {
        _snack(loginRes.message, isError: true);
      }
    } catch (e) {
      _snack(e.toString(), isError: true);
    } finally {
      _setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Gradient background
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _AppColors.deepBlue,
                      _AppColors.brand,
                      _AppColors.brand,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Expanded(
                    child: Image.asset(AssetImageUtils.onboardingBgImage),
                  ),
                  if (_sheet == _Sheet.none)
                    _BottomCard(
                      title: "PhoneKing",
                      subtitle:
                          "Your gateway to exclusive rewards,\namazing deals and premium services",
                      buttonText: "Get Started",
                      onPressed: _busy ? null : _openPhone,
                      secondary: TextButton(
                        onPressed: _busy ? null : _openLogin,
                        child: const Text(
                          "Already have an account? Log in",
                          style: TextStyle(
                            color: _AppColors.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Scrim + animated sheet
            if (_sheet != _Sheet.none) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: _busy ? null : _closeAny,
                  child: AnimatedBuilder(
                    animation: _ac,
                    builder: (_, _) => ColoredBox(
                      // 🔧 safer API than withValues
                      color: Colors.black.withValues(alpha: .35 * _ac.value),
                    ),
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
                        _Sheet.phone => _PhoneFormCard(
                          enabled: !_busy,
                          onConfirm: _handleSendOtp,
                          onTapLogin: _openLogin,
                        ),
                        _Sheet.otp => _OtpFormCard(
                          enabled: !_busy,
                          onConfirm: _handleVerifyOtp,
                          onResend: () {
                            if (_phone != null) _handleSendOtp(_phone!);
                          },
                        ),
                        _Sheet.pin => _PinFormCard(
                          enabled: !_busy,
                          onConfirm: _handleSetPin,
                        ),
                        _Sheet.personal => _PersonalInfoFormCard(
                          enabled: !_busy,
                          onConfirm: _handleRegister,
                        ),
                        _Sheet.login => _LoginFormCard(
                          enabled: !_busy,
                          onConfirm: _handleLogin,
                          onTapRegister: _openPhone,
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ),
              ),
            ],

            // Loading overlay
            if (_busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/*─────────────────────────────────────────────────────────────────────────────*
 * STEP 1: Phone sheet  (Register Flow)
 *─────────────────────────────────────────────────────────────────────────────*/

class _PhoneFormCard extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onConfirm; // returns phone with +95
  final VoidCallback onTapLogin;

  const _PhoneFormCard({
    required this.onConfirm,
    required this.enabled,
    required this.onTapLogin,
  });

  @override
  State<_PhoneFormCard> createState() => _PhoneFormCardState();
}

class _PhoneFormCardState extends State<_PhoneFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _validateMmPhone(String v) {
    final raw = v.trim();
    if (raw.isEmpty) return 'Phone is required';
    if (!RegExp(r'^\d{7,11}$').hasMatch(raw)) return 'Invalid Myanmar number';
    return null;
  }

  void _submit() {
    if (!widget.enabled) return;
    final form = _formKey.currentState;
    if (form?.validate() != true) return;
    final full = _phoneCtrl.text.trim();
    widget.onConfirm(full);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.white,
      borderRadius: _Styles.sheetRadius,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _grabber(),
                const Text("Unlock Amazing Benefits", style: _Styles.h1),
                _Gaps.v18,

                _label("Phone Number"),
                _Gaps.v8,

                SizedBox(
                  height: 52,
                  child: TextFormField(
                    controller: _phoneCtrl,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) => _validateMmPhone(v ?? ''),
                    decoration: _Decorations.inputRoundedAll(
                      hint: "type your phone number",
                    ),
                  ),
                ),

                _Gaps.v18,
                _PrimaryButton(
                  text: "Send OTP",
                  onPressed: widget.enabled ? _submit : null,
                ),
                _Gaps.v8,
                TextButton(
                  onPressed: widget.enabled ? widget.onTapLogin : null,
                  child: const Text(
                    "Already have an account? Log in",
                    style: TextStyle(
                      color: _AppColors.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*─────────────────────────────────────────────────────────────────────────────*
 * STEP 2: OTP Verification sheet (6 digits)
 *─────────────────────────────────────────────────────────────────────────────*/

class _OtpFormCard extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onConfirm; // returns otp
  final VoidCallback onResend;

  const _OtpFormCard({
    required this.enabled,
    required this.onConfirm,
    required this.onResend,
  });

  @override
  State<_OtpFormCard> createState() => _OtpFormCardState();
}

class _OtpFormCardState extends State<_OtpFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  String? _validateOtp(String v) {
    final s = v.trim();
    if (s.length != 6 || int.tryParse(s) == null) return "OTP must be 6 digits";
    return null;
  }

  void _submit() {
    if (!widget.enabled) return;
    final form = _formKey.currentState;
    if (form?.validate() != true) return;
    widget.onConfirm(_otp.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.white,
      borderRadius: _Styles.sheetRadius,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _grabber(),
                const Text("Verify OTP", style: _Styles.h1),
                _Gaps.v18,

                _label("Enter 6-digit code"),
                _Gaps.v8,
                SizedBox(
                  height: 52,
                  child: TextFormField(
                    controller: _otp,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    buildCounter:
                        (
                          _, {
                          int? currentLength,
                          bool? isFocused,
                          int? maxLength,
                        }) => const SizedBox.shrink(),
                    validator: (v) => _validateOtp(v ?? ''),
                    decoration: _Decorations.inputRoundedAll(
                      hint: "e.g. 123456",
                    ),
                  ),
                ),

                _Gaps.v18,
                _PrimaryButton(
                  text: "Verify",
                  onPressed: widget.enabled ? _submit : null,
                ),
                _Gaps.v8,
                TextButton(
                  onPressed: widget.enabled ? widget.onResend : null,
                  child: const Text("Resend OTP"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*─────────────────────────────────────────────────────────────────────────────*
 * STEP 3: Create PIN sheet
 *─────────────────────────────────────────────────────────────────────────────*/

class _PinFormCard extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onConfirm; // returns pin

  const _PinFormCard({required this.onConfirm, required this.enabled});

  @override
  State<_PinFormCard> createState() => _PinFormCardState();
}

class _PinFormCardState extends State<_PinFormCard> {
  final _formKey = GlobalKey<FormState>();
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

  void _submit() {
    if (!widget.enabled) return;
    final form = _formKey.currentState;
    if (form?.validate() != true) return;
    if (_pin1.text != _pin2.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PINs do not match")));
      return;
    }
    widget.onConfirm(_pin1.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.white,
      borderRadius: _Styles.sheetRadius,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _grabber(),
                const Text("Create Your Safety Pin", style: _Styles.h1),
                _Gaps.v18,

                _label("PIN Number"),
                _Gaps.v8,
                _pinField(
                  controller: _pin1,
                  obscure: _ob1,
                  onToggle: () => setState(() => _ob1 = !_ob1),
                  validator: (v) => _validatePin(v ?? ''),
                  enabled: widget.enabled,
                ),

                _Gaps.v18,
                _label("Confirm PIN Number"),
                _Gaps.v8,
                _pinField(
                  controller: _pin2,
                  obscure: _ob2,
                  onToggle: () => setState(() => _ob2 = !_ob2),
                  validator: (v) => _validatePin(v ?? ''),
                  enabled: widget.enabled,
                ),

                _Gaps.v18,
                _PrimaryButton(
                  text: "Create",
                  onPressed: widget.enabled ? _submit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pinField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    required bool enabled,
  }) {
    return SizedBox(
      height: 52,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        keyboardType: TextInputType.number,
        maxLength: 6,
        validator: validator,
        buildCounter:
            (_, {int? currentLength, bool? isFocused, int? maxLength}) =>
                const SizedBox(),
        decoration: _Decorations.inputRoundedAll(
          hint: "must be 6 digits",
          suffix: IconButton(
            onPressed: onToggle,
            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          ),
        ),
      ),
    );
  }
}

/*─────────────────────────────────────────────────────────────────────────────*
 * STEP 4: Personal Info sheet
 *─────────────────────────────────────────────────────────────────────────────*/

class _PersonalInfoFormCard extends StatefulWidget {
  final bool enabled;
  final Future<void> Function({
    required String name,
    required String day,
    required String month,
    required String year,
  })
  onConfirm;

  const _PersonalInfoFormCard({required this.onConfirm, required this.enabled});

  @override
  State<_PersonalInfoFormCard> createState() => _PersonalInfoFormCardState();
}

class _PersonalInfoFormCardState extends State<_PersonalInfoFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _day, _month, _year;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String v) {
    if (v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Please enter a valid name';
    return null;
  }

  Future<void> _submit() async {
    if (!widget.enabled) return;
    final form = _formKey.currentState;
    if (form?.validate() != true) return;
    if (_day == null || _month == null || _year == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    await widget.onConfirm(
      name: _nameCtrl.text.trim(),
      day: _day!,
      month: _month!,
      year: _year!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.white,
      borderRadius: _Styles.sheetRadius,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _grabber(),
                const Text("Fill Your Personal Info", style: _Styles.h1),
                _Gaps.v18,

                _label("Your Name"),
                _Gaps.v8,
                TextFormField(
                  controller: _nameCtrl,
                  enabled: widget.enabled,
                  textInputAction: TextInputAction.done,
                  validator: (v) => _validateName(v ?? ''),
                  decoration: _Decorations.inputRoundedAll(
                    hint: "Enter Your Name",
                  ),
                ),

                _Gaps.v18,
                _label("Your Birthday"),
                _Gaps.v8,
                Row(
                  children: [
                    Expanded(
                      child: _birthdayDropdown(
                        start: 1,
                        end: 31,
                        value: _day,
                        onChanged: (v) => setState(() => _day = v),
                        enabled: widget.enabled,
                        hint: 'DD',
                      ),
                    ),
                    _Gaps.h8,
                    Expanded(
                      child: _birthdayDropdown(
                        start: 1,
                        end: 12,
                        value: _month,
                        onChanged: (v) => setState(() => _month = v),
                        enabled: widget.enabled,
                        hint: 'MM',
                      ),
                    ),
                    _Gaps.h8,
                    Expanded(
                      child: _birthdayDropdown(
                        start: 1960,
                        end: DateTime.now().year,
                        value: _year,
                        onChanged: (v) => setState(() => _year = v),
                        enabled: widget.enabled,
                        hint: 'YYYY',
                      ),
                    ),
                  ],
                ),

                _Gaps.v24,
                _PrimaryButton(
                  text: "Confirm",
                  onPressed: widget.enabled ? _submit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _birthdayDropdown({
    required int start,
    required int end,
    required String? value,
    required ValueChanged<String?> onChanged,
    required bool enabled,
    required String hint,
  }) {
    final items = List.generate(end - start + 1, (i) => (start + i).toString());
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _Decorations.inputRoundedAll(),
      hint: Text(hint),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: (v) => (v == null) ? 'Required' : null,
    );
  }
}

/*─────────────────────────────────────────────────────────────────────────────*
 * LOGIN sheet
 *─────────────────────────────────────────────────────────────────────────────*/

class _LoginFormCard extends StatefulWidget {
  final bool enabled;
  final Future<void> Function(String phone, String password) onConfirm;
  final VoidCallback onTapRegister;

  const _LoginFormCard({
    required this.enabled,
    required this.onConfirm,
    required this.onTapRegister,
  });

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  String? _validateMmPhone(String v) {
    final raw = v.trim();
    if (raw.isEmpty) return 'Phone is required';
    if (!RegExp(r'^\d{7,11}$').hasMatch(raw)) return 'Invalid Myanmar number';
    return null;
  }

  String? _validatePwd(String v) {
    if (v.isEmpty) return 'Password required';
    if (v.length < 4) return 'Too short';
    return null;
  }

  void _submit() {
    if (!widget.enabled) return;
    final form = _formKey.currentState;
    if (form?.validate() != true) return;
    final full = _phoneCtrl.text.trim();
    widget.onConfirm(full, _pwdCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.white,
      borderRadius: _Styles.sheetRadius,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _grabber(),
                const Text("Welcome back", style: _Styles.h1),
                _Gaps.v18,

                _label("Phone Number"),
                _Gaps.v8,
                TextFormField(
                  controller: _phoneCtrl,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) => _validateMmPhone(v ?? ''),
                  decoration: _Decorations.inputRoundedAll(
                    hint: "type your phone number",
                  ),
                ),

                _Gaps.v18,
                _label("Password / PIN"),
                _Gaps.v8,
                SizedBox(
                  height: 52,
                  child: TextFormField(
                    controller: _pwdCtrl,
                    enabled: widget.enabled,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) => _validatePwd(v ?? ''),
                    decoration: _Decorations.inputRoundedAll(
                      hint: "your password",
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                ),

                _Gaps.v18,
                _PrimaryButton(
                  text: "Log in",
                  onPressed: widget.enabled ? _submit : null,
                ),
                _Gaps.v8,
                TextButton(
                  onPressed: widget.enabled ? widget.onTapRegister : null,
                  child: const Text(
                    "New here? Create account",
                    style: TextStyle(
                      color: _AppColors.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*─────────────────────────────────────────────────────────────────────────────*
 * Shared tiny widgets & styles
 *─────────────────────────────────────────────────────────────────────────────*/

class _BottomCard extends StatelessWidget {
  final String title, subtitle, buttonText;
  final VoidCallback? onPressed;
  final Widget? secondary;

  const _BottomCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    this.secondary,
  });

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
          Image.asset(AssetImageUtils.appLogo, width: 200),
          _Gaps.v32,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: _AppColors.text,
            ),
          ),
          _Gaps.v28,
          _PrimaryButton(text: buttonText, onPressed: onPressed),
          if (secondary != null) ...[_Gaps.v8, secondary!],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
    );
  }
}

Widget _label(String t) => Align(
  alignment: Alignment.centerLeft,
  child: Text(
    t,
    style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
  ),
);

Widget _grabber() => Container(
  width: 56,
  height: 5,
  margin: const EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: _AppColors.stroke,
    borderRadius: BorderRadius.circular(12),
  ),
);

class _Decorations {
  static InputDecoration inputRoundedAll({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: _AppColors.fill,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: _AppColors.stroke),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _AppColors.stroke),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _AppColors.brand, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _Styles {
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(32),
  );
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );
}

class _Gaps {
  static const v8 = SizedBox(height: 8);
  static const v18 = SizedBox(height: 18);
  static const v24 = SizedBox(height: 24);
  static const v28 = SizedBox(height: 28);
  static const v32 = SizedBox(height: 32);
  static const h8 = SizedBox(width: 8);
}

class _AppColors {
  static const primary = Color(0xFF0C34FF);
  static const deepBlue = Color(0xFF0C1B4D);
  static const brand = Color(0xFFED5B23);
  static const fill = Color(0xFFF7F8FB);
  static const stroke = Color(0xFFE6E8F0);
  static const text = Color(0xFF384053);
}
