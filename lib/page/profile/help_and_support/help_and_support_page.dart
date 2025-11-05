

import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/support/phone_king_support_model_impl.dart';
import 'package:phone_king_customer/data/vos/contact_us_vo/contact_us_vo.dart';
import 'package:phone_king_customer/data/vos/faq_vo/faq_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({super.key});

  @override
  State<HelpAndSupportPage> createState() => _HelpAndSupportPageState();
}

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
      // fetch in parallel
      final results = await Future.wait([
        _supportModel.getSupportFaqs(),
        _supportModel.getContactUs(),
      ]);

      if (!mounted) return;
      final BaseResponse<List<FaqVO>> faqsRes =
      results[0] as BaseResponse<List<FaqVO>>;
      final BaseResponse<List<ContactUsVO>> contactsRes =
      results[1] as BaseResponse<List<ContactUsVO>>;

      setState(() {
        _faqs = faqsRes.data ?? const <FaqVO>[];
        _contactUs = contactsRes.data ?? const <ContactUsVO>[];
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

  // Helpers to extract contact by type
  ContactUsVO? _firstByType(String type) {
    try {
      return _contactUs.firstWhere(
            (e) => (e.contactType ?? '').toUpperCase() == type.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> _launchEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: {
        'subject': 'Support Request',
      }.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&'),
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final loadingOverlay = Positioned.fill(
      child: IgnorePointer(
        ignoring: !_isLoading,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _isLoading ? 1 : 0,
          child: Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );

    final errorBanner = (_error?.isNotEmpty ?? false)
        ? Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFC9C9)),
      ),
      child: Text(
        _error ?? '',
        style: const TextStyle(
          color: Color(0xFFB00020),
          fontSize: 12,
        ),
      ),
    )
        : const SizedBox.shrink();

    final phone = _firstByType('PHONE')?.contact ?? '';
    final email = _firstByType('EMAIL')?.contact ?? '';
    final hours = _firstByType('HOURS')?.contact ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAll,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // Error banner (if any)
                errorBanner,

                Text('Contact Us', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.phone_in_talk_rounded,
                        title: 'Call Us',
                        subtitle: phone.isEmpty ? '—' : phone,
                        onTap: phone.isEmpty ? null : () => _launchPhone(phone),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.mail_rounded,
                        title: 'Email Us',
                        subtitle: email.isEmpty ? '—' : email,
                        onTap: email.isEmpty ? null : () => _launchEmail(email),
                      ),
                    ),
                  ],
                ),

                if (hours.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Business Hours: $hours',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                Text(
                  'Frequently Asked Questions',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                if (!_isLoading && _faqs.isEmpty)
                  Text(
                    'No FAQs available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  )
                else
                  ..._faqs.map(
                        (f) => _FaqTile(
                      item: _FaqItem(
                        question: f.question ?? '',
                        answer: f.answer ?? '',
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Loading overlay
          loadingOverlay,
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor.withValues(alpha: .2)),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 2),
              color: Colors.black.withValues(alpha: .04),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.isEmpty ? '—' : subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

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
        border: Border.all(color: theme.dividerColor.withValues(alpha: .25)),
        color: theme.colorScheme.surface,
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(item.question, style: theme.textTheme.bodyLarge),
          trailing: const Icon(Icons.keyboard_arrow_down_rounded),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
