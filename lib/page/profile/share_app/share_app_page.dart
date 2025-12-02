import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_king_customer/persistent/login_persistent.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';

class ShareAppPage extends StatefulWidget {
  const ShareAppPage({super.key});

  @override
  State<ShareAppPage> createState() => _ShareAppPageState();
}

class _ShareAppPageState extends State<ShareAppPage> {
  final LoginPersistent _loginPersistent = LoginPersistent();

  String? _referralCode;

  @override
  void initState() {
    super.initState();
    _loadReferral();
  }

  Future<void> _loadReferral() async {
    final data = await _loginPersistent.getLoginData();
    if (!mounted) return;
    setState(() {
      _referralCode = data?.referralCode ?? '';
    });
  }

  bool get _hasReferral => _referralCode != null && _referralCode!.isNotEmpty;

  String get _shareMessage {
    final code = _referralCode ?? '';
    return '''
Join me on Phone King and earn points together!  
Use my referral code: $code  

Download the app from the store and enter this code during signup.
''';
  }

  void _copyReferral(BuildContext context) {
    if (!_hasReferral) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral link not available yet'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: _referralCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral link copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Later you can plug this into share_plus:
  // Share.share(_shareMessage);
  void _shareTo(BuildContext context, String channel) {
    if (!_hasReferral) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral link not available yet'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // For now just copy and show toast.
    Clipboard.setData(ClipboardData(text: _shareMessage));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral message copied for $channel'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.black87,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Share App',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            _inviteCard(context),
            const SizedBox(height: 24),
            _shareViaCard(context),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  Widget _inviteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Invite Friends',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Invite your friends to join Phone King\n'
                'and earn 1,000 Pts per person.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Gradient container
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA86B), Color(0xFFB85C32)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your referral link',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _referralCode ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      height: 40,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _copyReferral(context),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  Widget _shareViaCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Share Via',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SocialIconButton(
                assetPath: AssetImageUtils.facebookIcon,
                onTap: () => _shareTo(context, 'Facebook'),
              ),
              _SocialIconButton(
                assetPath: AssetImageUtils.instagramIcon,
                onTap: () => _shareTo(context, 'Instagram'),
              ),
              _SocialIconButton(
                assetPath: AssetImageUtils.viberIcon,
                onTap: () => _shareTo(context, 'Viber'),
              ),
              _SocialIconButton(
                assetPath: AssetImageUtils.telegramIcon,
                onTap: () => _shareTo(context, 'Telegram'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------
//     SOCIAL ICON BUTTON (ASSETS)
// -----------------------------------
class _SocialIconButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _SocialIconButton({required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(12),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}
