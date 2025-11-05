

import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/support/phone_king_support_model_impl.dart';
import 'package:phone_king_customer/data/vos/branches_vo/branches_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactBranchesPage extends StatefulWidget {
  const ContactBranchesPage({super.key});

  @override
  State<ContactBranchesPage> createState() => _ContactBranchesPageState();
}

class _ContactBranchesPageState extends State<ContactBranchesPage> {
  final _supportModel = PhoneKingSupportModelImpl();

  bool _isLoading = false;
  String? _error;
  List<BranchesVO> _branches = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBranches());
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final BaseResponse<List<BranchesVO>> res =
      await _supportModel.getSupportBranches();
      if (!mounted) return;
      setState(() {
        _branches = res.data ?? const <BranchesVO>[];
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

  Future<void> _onRefresh() => _loadBranches();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Branches'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadBranches,
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
                Text('Our Branches', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Visit any of our branches for repairs, purchases, and support',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Error banner (if any)
                errorBanner,

                if (!_isLoading && _branches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'No branches available.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  )
                else
                  ..._branches.map((b) => _BranchCard(branch: b)),
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

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});

  final BranchesVO branch;

  Color get _accent => const Color(0xFFFF6A00);

  Future<void> _call() async {
    final phone = branch.phoneNumber?.trim();
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections() async {
    final lat = branch.latitude;
    final lng = branch.longitude;
    if (lat == null || lng == null) return;

    final googleMaps = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&destination=$lat,$lng'
          '&travelmode=driving',
    );
    if (await canLaunchUrl(googleMaps)) {
      await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
      return;
    }

    final geo = Uri.parse(
      'geo:$lat,$lng?q=${Uri.encodeComponent(branch.location ?? '')}',
    );
    if (await canLaunchUrl(geo)) {
      await launchUrl(geo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orange = _accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              branch.name ?? 'Unnamed Branch',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            // Address / location
            if ((branch.location ?? '').isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_rounded, size: 20, color: orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      branch.location!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

            if ((branch.location ?? '').isNotEmpty) const SizedBox(height: 10),

            // Phone
            if ((branch.phoneNumber ?? '').isNotEmpty)
              Row(
                children: [
                  Icon(Icons.phone_rounded, size: 20, color: orange),
                  const SizedBox(width: 10),
                  Text(
                    branch.phoneNumber!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: orange),
                  ),
                ],
              ),

            // Opening time
            if ((branch.openingTime ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.access_time_rounded, size: 20, color: orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      branch.openingTime!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (branch.phoneNumber ?? '').isEmpty ? null : _call,
                    icon: const Icon(Icons.call_rounded),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                    (branch.latitude == null || branch.longitude == null)
                        ? null
                        : _openDirections,
                    icon: const Icon(Icons.near_me_rounded),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
