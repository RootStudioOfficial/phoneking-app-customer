import 'package:flutter/material.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
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
                    // avatar
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEF4444)),
                      child: Center(child: Image.asset(AssetImageUtils.profileIcon, width: 28, height: 28, color: Colors.white)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'John Doe',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                              ),
                              // edit icon
                              Icon(Icons.edit_outlined, size: 18, color: Color(0xFF9AA3B2)),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text('09420148498', style: TextStyle(color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE6E8F0)),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(
                      child: _StatTile(label: 'Member', value: '🥇 Gold', valueColor: Color(0xFFEEB60A)),
                    ),
                    Expanded(
                      child: _StatTile(label: 'Points', value: '11,968'),
                    ),
                    Expanded(
                      child: _StatTile(label: 'Rewards', value: '2'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _sectionTitle('General'),
          _cardList(
            children: const [
              _SettingTile(asset: AssetImageUtils.changePinIcon, label: 'Change Pin'),
              _DividerTile(),
              _SettingTile(asset: AssetImageUtils.shareAppIcon, label: 'Share App'),
            ],
          ),

          const SizedBox(height: 18),
          _sectionTitle('Support'),
          _cardList(
            children: const [
              _SettingTile(asset: AssetImageUtils.helpAndSupportIcon, label: 'Help & Support'),
              _DividerTile(),
              _SettingTile(asset: AssetImageUtils.contactBranchesIcon, label: 'Contact Branches'),
              _DividerTile(),
              _SettingTile(asset: AssetImageUtils.termsAndConditionIcon, label: 'Terms & Conditions'),
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
            child: const _SettingTile(asset: AssetImageUtils.signOutIcon, label: 'Sign Out', labelColor: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 130),
        ],
      ),
    );
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
            style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: valueColor ?? const Color(0xFF0F172A), fontWeight: FontWeight.w800),
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
    style: const TextStyle(color: Color(0xFF818898), fontWeight: FontWeight.w700),
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

  const _SettingTile({required this.asset, required this.label, this.labelColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: const Color(0xFFF2F4F8), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Image.asset(asset, width: 20, height: 20, color: const Color(0xFF6B7280))),
      ),
      title: Text(
        label,
        style: TextStyle(color: labelColor ?? const Color(0xFF0F172A), fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9AA3B2)),
      onTap: () {
        // TODO: hook up navigation
      },
    );
  }
}

class _DividerTile extends StatelessWidget {
  const _DividerTile();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE6E8F0));
  }
}
