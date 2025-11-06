import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_king_customer/data/model/auth/phone_king_auth_model_impl.dart';
import 'package:phone_king_customer/data/model/profile/phone_king_profile_model_impl.dart';
import 'package:phone_king_customer/data/vos/member_tier_vo/member_tier_vo.dart';
import 'package:phone_king_customer/data/vos/user_vo/user_vo.dart';
import 'package:phone_king_customer/page/auth/onboarding_page.dart';
import 'package:phone_king_customer/page/profile/change_pin/change_pin_page.dart';
import 'package:phone_king_customer/page/profile/contact_branches/contact_branches_page.dart';
import 'package:phone_king_customer/page/profile/help_and_support/help_and_support_page.dart';
import 'package:phone_king_customer/page/profile/terms_and_condition/terms_and_condition_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // models
  final _authModel = PhoneKingAuthModelImpl();
  final _profileModel = PhoneKingProfileModelImpl();

  // state
  bool _loading = false;
  bool _updating = false;
  String? _error;

  UserVO? _user;
  MemberTierVO? _tier;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resUser = await _profileModel.getProfile();
      final resTier = await _profileModel.getMemberTier();
      if (!mounted) return;
      setState(() {
        _user = resUser.data;
        _tier = resTier.data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEdit() async {
    if (_user == null) return;

    final result = await openEditProfile(
      context,
      _user!.displayName ?? _user!.username,
      _user!.phoneNumber ?? '',
      null, // if you later add profile image url in UserVO, pass it here
    );

    if (result == null) return;

    // result: {'name':..., 'phone':..., 'imagePath': ...? }
    final String newName = (result['name'] as String).trim();
    final String newPhone = (result['phone'] as String).trim();
    final String? imagePath = result['imagePath'] as String?;

    if (newName.isEmpty || newPhone.isEmpty) {
      if (mounted) {
        context.showErrorSnackBar('Name/Phone cannot be empty');
      }
      return;
    }

    if (_updating) return;

    setState(() => _updating = true);
    try {
      String uploadedUrl = '';

      // 1) upload file if selected
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        final uploadRes = await _profileModel.uploadFile(file, 'profile');
        uploadedUrl = uploadRes.data ?? '';
      }

      // 2) update profile
      await _profileModel.updateProfile(
        uploadedUrl,
        // can be '' if not changed. Your backend can treat as unchanged.
        newName,
        newPhone,
      );

      // 3) refresh profile
      await _loadAll();

      if (!mounted) return;
      context.showSuccessSnackBar('Profile updated');
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.displayName ?? _user?.username ?? '—';
    final phone = _user?.phoneNumber ?? '—';
    final memberLabel = _tier?.tier.name ?? '—';
    final memberColor =
        _safeColor(_tier?.tier.colorCode) ?? const Color(0xFFEEB60A);
    final points = _formatPoints(
      _tier?.currentBalance,
    ); // show balance as points
    final totalRewards = (_tier?.totalClaimRewards ?? 0).toString();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: _loading ? null : _loadAll,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAEA),
                    border: Border.all(color: const Color(0xFFFFC9C9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFB00020)),
                  ),
                ),
              ],

              // Profile summary card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE6E8F0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // avatar (placeholder / initial)
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEF4444),
                          ),
                          child: Center(
                            child: Image.asset(
                              AssetImageUtils.profileIcon,
                              width: 28,
                              height: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  // edit icon
                                  GestureDetector(
                                    onTap: _updating ? null : _openEdit,
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: Color(0xFF9AA3B2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                phone,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE6E8F0)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Member',
                            value: '🥇$memberLabel',
                            valueColor: memberColor,
                          ),
                        ),
                        Expanded(
                          child: _StatTile(label: 'Points', value: points),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'Rewards',
                            value: totalRewards,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              _sectionTitle('General'),
              _cardList(
                children: [
                  _SettingTile(
                    asset: AssetImageUtils.changePinIcon,
                    label: 'Change Pin',
                    onTap: () =>
                        context.navigateToNextPage(const ChangePinPage()),
                  ),
                  const _DividerTile(),
                  _SettingTile(
                    asset: AssetImageUtils.shareAppIcon,
                    label: 'Share App',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 18),
              _sectionTitle('Support'),
              _cardList(
                children: [
                  _SettingTile(
                    asset: AssetImageUtils.helpAndSupportIcon,
                    label: 'Help & Support',
                    onTap: () =>
                        context.navigateToNextPage(const HelpAndSupportPage()),
                  ),
                  const _DividerTile(),
                  _SettingTile(
                    asset: AssetImageUtils.contactBranchesIcon,
                    label: 'Contact Branches',
                    onTap: () =>
                        context.navigateToNextPage(const ContactBranchesPage()),
                  ),
                  const _DividerTile(),
                  _SettingTile(
                    asset: AssetImageUtils.termsAndConditionIcon,
                    label: 'Terms & Conditions',
                    onTap: () => context.navigateToNextPage(
                      const TermsAndConditionPage(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Sign out card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE6E8F0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _SettingTile(
                  asset: AssetImageUtils.signOutIcon,
                  label: 'Sign Out',
                  labelColor: const Color(0xFFEF4444),
                  onTap: _loading || _updating
                      ? null
                      : () {
                          _authModel
                              .logout()
                              .then((_) {
                                if (context.mounted) {
                                  context.showSuccessSnackBar(
                                    "Logout Success.",
                                  );
                                  context.navigateToNextPageWithRemoveUntil(
                                    const OnBoardingPage(),
                                  );
                                }
                              })
                              .catchError((error) {
                                if (context.mounted) {
                                  context.showErrorSnackBar(error.toString());
                                }
                              });
                        },
                ),
              ),

              const SizedBox(height: 130),
            ],
          ),
        ),

        // loading overlays
        if (_loading || _updating)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static String _formatPoints(double? v) {
    if (v == null) return '0';
    final intPts = v.round();
    return _num(intPts);
  }

  static String _num(num n) {
    final s = n.toString();
    final rgx = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(rgx, (m) => ',');
  }

  static Color? _safeColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var value = hex.replaceAll('#', '').toUpperCase();
    if (value.length == 6) value = 'FF$value';
    try {
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return null;
    }
  }
}

// ======= Bits & pieces =======

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionTitle(String text) => Padding(
  padding: const EdgeInsets.only(left: 4, bottom: 8),
  child: Text(
    text,
    style: const TextStyle(
      color: Color(0xFF818898),
      fontWeight: FontWeight.w700,
    ),
  ),
);

Widget _cardList({required List<Widget> children}) => Container(
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFE6E8F0)),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(children: children),
);

class _SettingTile extends StatelessWidget {
  final String asset;
  final String label;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.asset,
    required this.label,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Image.asset(
            asset,
            width: 20,
            height: 20,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? const Color(0xFF0F172A),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9AA3B2)),
      onTap: onTap,
    );
  }
}

class _DividerTile extends StatelessWidget {
  const _DividerTile();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Color(0xFFE6E8F0),
    );
  }
}

// ======================= Edit Profile Dialog =======================

class EditProfileDialog extends StatefulWidget {
  final String initialName;
  final String phoneNumber;
  final String? profileImageUrl;

  const EditProfileDialog({
    super.key,
    required this.initialName,
    required this.phoneNumber,
    this.profileImageUrl,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    }
  }

  void _saveChanges() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      context.showErrorSnackBar('Please enter your full name');
      return;
    }
    if (phone.isEmpty) {
      context.showErrorSnackBar('Please enter your phone');
      return;
    }

    context.navigateBack({
      'name': name,
      'phone': phone,
      'imagePath': _selectedImage?.path,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // avatar
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (widget.profileImageUrl != null &&
                              widget.profileImageUrl!.isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              widget.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildDefaultAvatar(),
                            ),
                          )
                        : _buildDefaultAvatar(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.deepOrange,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Click camera to change picture',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Full name
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'John Doe',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // phone (read-only)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: widget.phoneNumber),
              readOnly: true,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Phone number cannot be changed',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 32),

            // buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _buildDefaultAvatar() =>
      const Icon(Icons.person, size: 60, color: Colors.white);
}

// helper: show dialog
Future<Map<String, dynamic>?> showEditProfileDialog(
  BuildContext context, {
  required String initialName,
  required String phoneNumber,
  String? profileImageUrl,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => EditProfileDialog(
      initialName: initialName,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
    ),
  );
}

Future<Map<String, dynamic>?> openEditProfile(
  BuildContext context,
  String userName,
  String phoneNumber,
  String? profileImage,
) async {
  final result = await showEditProfileDialog(
    context,
    initialName: userName,
    phoneNumber: phoneNumber,
    profileImageUrl: profileImage,
  );
  return result;
}
