import 'package:flutter/material.dart';
import 'package:phonekingcustomer/data/model/support/phone_king_support_model_impl.dart';
import 'package:phonekingcustomer/data/vos/contact_us_vo/contact_us_vo.dart';
import 'package:phonekingcustomer/data/vos/faq_vo/faq_vo.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({super.key});

  @override
  State<HelpAndSupportPage> createState() => _HelpAndSupportPageState();
}

// ================== Typography Helper ==================

class _HelpSupportTextStyles {
  static const appBarTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black);

  static const sectionTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827));

  static const sectionSubtitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF6B7280), height: 1.4);

  static const errorBanner = TextStyle(color: Color(0xFFB00020), fontSize: 12, fontWeight: FontWeight.w500);

  static const emptyState = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF));

  static const contactCardTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827));

  static const contactCardSubtitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280));

  static const businessHours = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF16A34A));

  static const faqQuestion = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827));

  static const faqAnswer = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF6B7280), height: 1.5);
}

// ================== Page ==================

class _HelpAndSupportPageState extends State<HelpAndSupportPage> {
  final _supportModel = PhoneKingSupportModelImpl();

  bool _isLoading = false;
  String? _error;

  List<ContactUsVO> _contactUs = const [];
  List<FaqVO> _faqs = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([_supportModel.getSupportFaqs(), _supportModel.getContactUs()]);

      if (!mounted) return;

      final BaseResponse<List<FaqVO>> faqsRes = results[0] as BaseResponse<List<FaqVO>>;
      final BaseResponse<List<ContactUsVO>> contactsRes = results[1] as BaseResponse<List<ContactUsVO>>;

      setState(() {
        _faqs = faqsRes.data ?? const [];
        _contactUs = contactsRes.data ?? const [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() => _loadAll();

  ContactUsVO? _firstByType(String type) {
    try {
      return _contactUs.firstWhere((e) => (e.contactType ?? '').toUpperCase() == type.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  static Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email, query: 'subject=${Uri.encodeComponent('Support Request')}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final phone = _firstByType('PHONE')?.contact ?? '';
    final email = _firstByType('EMAIL')?.contact ?? '';
    final hours = _firstByType('HOURS')?.contact ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: _HelpSupportTextStyles.appBarTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _isLoading ? null : _loadAll)],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEAEA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFC9C9)),
                    ),
                    child: Text(_error!, style: _HelpSupportTextStyles.errorBanner),
                  ),

                const SizedBox(height: 12),
                const Text('Contact Us', style: _HelpSupportTextStyles.sectionTitle),
                const SizedBox(height: 4),
                const Text(
                  'Need help with your account, payments, or points? Reach us through the channels below.',
                  style: _HelpSupportTextStyles.sectionSubtitle,
                ),
                const SizedBox(height: 16),

                // ✅ VERTICAL CONTACT CARDS
                Column(
                  children: [
                    _ContactCard(
                      icon: Icons.phone_in_talk_rounded,
                      title: 'Call Us',
                      subtitle: phone.isEmpty ? '—' : phone,
                      onTap: phone.isEmpty ? null : () => _launchPhone(phone),
                    ),
                    const SizedBox(height: 12),
                    _ContactCard(
                      icon: Icons.mail_rounded,
                      title: 'Email Us',
                      subtitle: email.isEmpty ? '—' : email,
                      onTap: email.isEmpty ? null : () => _launchEmail(email),
                    ),
                  ],
                ),

                if (hours.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Business Hours: $hours', style: _HelpSupportTextStyles.businessHours)),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                const Text('Frequently Asked Questions', style: _HelpSupportTextStyles.sectionTitle),
                const SizedBox(height: 8),

                if (!_isLoading && _faqs.isEmpty)
                  const Text('No FAQs available.', style: _HelpSupportTextStyles.emptyState)
                else
                  ..._faqs.map(
                    (f) => _FaqTile(
                      item: _FaqItem(question: f.question ?? '', answer: f.answer ?? ''),
                    ),
                  ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// ================== Contact Card ==================

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _HelpSupportTextStyles.contactCardTitle),
                  const SizedBox(height: 4),
                  Text(subtitle, style: _HelpSupportTextStyles.contactCardSubtitle),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: primary),
          ],
        ),
      ),
    );
  }
}

// ================== FAQ ==================

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
        color: theme.colorScheme.surface,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(item.question, style: _HelpSupportTextStyles.faqQuestion),
        trailing: const Icon(Icons.keyboard_arrow_down_rounded),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(item.answer, style: _HelpSupportTextStyles.faqAnswer),
          ),
        ],
      ),
    );
  }
}
