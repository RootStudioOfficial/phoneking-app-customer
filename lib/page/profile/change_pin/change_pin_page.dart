import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_king_customer/page/auth/onboarding_page.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/data/model/profile/phone_king_profile_model_impl.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

// ========= Typography helper =========

class _ChangePinTextStyles {
  static const appBarTitle = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  static const subtitle = TextStyle(
    fontSize: 14,
    color: Color(0xFF6B7280), // grey-600 style
    fontWeight: FontWeight.w500,
  );

  static const fieldLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const hint = TextStyle(
    color: Color(0xFF9CA3AF),
    fontSize: 14,
  );

  static const helper = TextStyle(
    color: Color(0xFF6B7280),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class _ChangePinPageState extends State<ChangePinPage> {
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;
  bool _submitting = false;

  // API model
  final _profileModel = PhoneKingProfileModelImpl();

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _updatePin() async {
    final l10n = LocalizationString.of(context);

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate inputs
    final currentPin = _currentPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (currentPin.isEmpty) {
      context.showErrorSnackBar(l10n.changePinErrorEnterCurrentPin);
      return;
    }
    // At least 6 digits for new PIN
    if (newPin.length < 6) {
      context.showErrorSnackBar(l10n.changePinErrorNewPinLength);
      return;
    }
    if (newPin != confirmPin) {
      context.showErrorSnackBar(l10n.changePinErrorPinNotMatch);
      return;
    }
    if (_submitting) return;

    setState(() => _submitting = true);

    try {
      await _profileModel.changePassword(newPin, currentPin);

      if (!mounted) return;
      context.showSuccessSnackBar(l10n.changePinSuccessUpdated);
      context.navigateToNextPageWithRemoveUntil(const OnBoardingPage());
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderGrey = Color(0xFFE0E0E0);
    const deepOrange = Colors.deepOrange;

    final l10n = LocalizationString.of(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: _submitting ? null : () => Navigator.pop(context),
            ),
            title: Text(
              l10n.profileChangePin,
              style: _ChangePinTextStyles.appBarTitle,
            ),
          ),
          body: Column(
            children: [
              // Divider
              const Divider(height: 1, color: Color(0xFFEAEAEA)),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AbsorbPointer(
                    absorbing: _submitting,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileChangePin,
                          style: _ChangePinTextStyles.pageTitle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.profileUpdateYourSecurityPinForAccountAcces,
                          style: _ChangePinTextStyles.subtitle,
                        ),
                        const SizedBox(height: 32),

                        // Current PIN
                        Text(
                          l10n.profileCurrentPin,
                          style: _ChangePinTextStyles.fieldLabel,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _currentPinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: l10n.changePinHintCurrent,
                            hintStyle: _ChangePinTextStyles.hint,
                            filled: true,
                            fillColor: Colors.grey[50],
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: borderGrey,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: borderGrey,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: deepOrange,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // New PIN
                        Text(
                          l10n.profileNewPin,
                          style: _ChangePinTextStyles.fieldLabel,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPinController,
                          obscureText: _obscureNewPin,
                          keyboardType: TextInputType.number,
                          maxLength: 6, // 6 digits
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: l10n.changePinHintAtLeast8Digits,
                            helperText: l10n.changePinHelper8Digits,
                            helperStyle: _ChangePinTextStyles.helper,
                            hintStyle: _ChangePinTextStyles.hint,
                            filled: true,
                            fillColor: Colors.grey[50],
                            counterText: '',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPin
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(
                                      () => _obscureNewPin = !_obscureNewPin,
                                );
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: borderGrey,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: borderGrey,
                                width: 1,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                color: deepOrange,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Confirm PIN
                        Text(
                          l10n.profileConfirmNewPin,
                          style: _ChangePinTextStyles.fieldLabel,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPinController,
                          obscureText: _obscureConfirmPin,
                          keyboardType: TextInputType.number,
                          maxLength: 6, // 6 digits
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: l10n.changePinHintAtLeast8Digits,
                            helperText: l10n.changePinHelper8Digits,
                            helperStyle: _ChangePinTextStyles.helper,
                            hintStyle: _ChangePinTextStyles.hint,
                            filled: true,
                            fillColor: Colors.grey[50],
                            counterText: '',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPin
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(
                                      () => _obscureConfirmPin =
                                  !_obscureConfirmPin,
                                );
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: borderGrey,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: borderGrey,
                                width: 1,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                color: deepOrange,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Update Pin Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _updatePin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      l10n.changePinUpdatePinButton,
                      style: _ChangePinTextStyles.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Loading overlay
        if (_submitting)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 180),
                child: Container(color: Colors.black26),
              ),
            ),
          ),
      ],
    );
  }
}
