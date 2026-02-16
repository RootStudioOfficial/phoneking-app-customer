import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phonekingcustomer/data/model/notification/phone_king_notification_model.dart';
import 'package:phonekingcustomer/data/model/notification/phone_king_notification_model_impl.dart';
import 'package:phonekingcustomer/data/vos/notification_vo/notification_vo.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';
import 'package:phonekingcustomer/utils/asset_image_utils.dart';
import 'package:phonekingcustomer/utils/localization_strings.dart';

// ========= Typography helpers =========

class _NotificationTextStyles {
  static const appBarTitle = TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A));

  static const headerInfo = TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500);

  static const headerAction = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

  static const errorText = TextStyle(color: Color(0xFFB00020), fontSize: 12, fontWeight: FontWeight.w500);

  static const cardTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF101828));

  static const cardBody = TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.45, fontWeight: FontWeight.w400);

  static const cardTime = TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600);

  static const tagText = TextStyle(fontSize: 12, color: Color(0xFF5B667A), fontWeight: FontWeight.w600);
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final PhoneKingNotificationModel _model = PhoneKingNotificationModelImpl();

  final int _pageSize = 10;
  int _page = 0;
  bool _hasNext = true;

  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  final List<NotificationContentVO> _items = [];

  @override
  void initState() {
    super.initState();
    _load(first: true);
  }

  int get _unreadCount => _items.where((e) => !e.read).length;

  // ================= ICON MAPPING =================

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'TOP_UP':
        return Icons.account_balance_wallet;
      case 'POINT_ADJUST':
        return Icons.star;
      case 'REWARD_EXCHANGED':
        return Icons.card_giftcard;
      case 'TIER_UPDATE':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  // ================= API =================

  Future<void> _load({bool first = false}) async {
    if (_loading || _loadingMore) return;

    setState(() {
      if (first) {
        _loading = true;
        _page = 0;
        _items.clear();
        _hasNext = true;
      } else {
        _loadingMore = true;
      }
      _error = null;
    });

    try {
      final BaseResponse<NotificationVO> res = await _model.getAllNotification(_pageSize.toString(), _page.toString());

      final data = res.data;

      if (!mounted) return;

      if (data != null) {
        _items.addAll(data.content);
        _hasNext = !data.last;
        _page++;
      } else {
        _hasNext = false;
      }
    } catch (e) {
      if (!mounted) return;
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _refresh() async => _load(first: true);

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;

    final backup = List<NotificationContentVO>.from(_items);

    setState(() {
      for (var i = 0; i < _items.length; i++) {
        final n = _items[i];
        _items[i] = n.copyWith(read: true);
      }
    });

    try {
      await _model.readAllNotification();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(backup);
      });
    }
  }

  Future<void> _markOneAsRead(NotificationContentVO n, int index) async {
    if (n.read) return;

    setState(() {
      _items[index] = n.copyWith(read: true);
    });

    try {
      await _model.readNotificationByID(n.id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items[index] = n.copyWith(read: false);
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.notificationNotification, style: _NotificationTextStyles.appBarTitle),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Text('$_unreadCount ${l10n.notificationUnreadNotification}', style: _NotificationTextStyles.headerInfo),
                const Spacer(),
                GestureDetector(
                  onTap: _unreadCount == 0 ? null : _markAllAsRead,
                  child: Text(
                    l10n.notificationMarkAsAllRead,
                    style: _NotificationTextStyles.headerAction.copyWith(color: _unreadCount == 0 ? Colors.grey : const Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _loading && _items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _items.length + (_hasNext ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        if (i >= _items.length) {
                          if (_hasNext && !_loadingMore) {
                            scheduleMicrotask(() => _load());
                          }
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final n = _items[i];
                        return _NotificationCard(
                          title: n.title,
                          body: n.body,
                          tag: n.notificationType,
                          iconPath: _iconForType(n.notificationType),
                          timeLabel: _timeAgo(n.localDateTime),
                          isRead: n.read,
                          onTap: () => _markOneAsRead(n, i),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt);

      if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return raw;
    }
  }
}

// ================= CARD =================

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String tag;
  final IconData iconPath;
  final String timeLabel;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.tag,
    required this.iconPath,
    required this.timeLabel,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isRead ? const Color(0xFFF3F6FF).withValues(alpha: .55) : const Color(0xFFE9F0FF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD6E2FF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Icon(iconPath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: _NotificationTextStyles.cardTitle)),
                      Text(timeLabel, style: _NotificationTextStyles.cardTime),
                      if (!isRead)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: _Dot(color: Color(0xFF2F56FF)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(body, style: _NotificationTextStyles.cardBody),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFEDEFF3), borderRadius: BorderRadius.circular(10)),
                    child: Text(tag, style: _NotificationTextStyles.tagText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
