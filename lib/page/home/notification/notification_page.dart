import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/notification/phone_king_notification_model.dart';
import 'package:phone_king_customer/data/model/notification/phone_king_notification_model_impl.dart';
import 'package:phone_king_customer/data/vos/notification_vo/notification_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';

import 'dart:async';

import 'package:phone_king_customer/utils/localization_strings.dart';

// ========= Typography helpers =========

class _NotificationTextStyles {
  // AppBar title
  static const appBarTitle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 18,
    color: Color(0xFF0F172A),
  );

  // Header text: "X unread notifications"
  static const headerInfo = TextStyle(
    fontSize: 13,
    color: Color(0xFF4B5563),
    fontWeight: FontWeight.w500,
  );

  // "Mark all as read"
  static const headerAction = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // Error banner text
  static const errorText = TextStyle(
    color: Color(0xFFB00020),
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Notification title
  static const cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: Color(0xFF101828),
  );

  // Notification body
  static const cardBody = TextStyle(
    fontSize: 13,
    color: Color(0xFF4B5563),
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  // Time label
  static const cardTime = TextStyle(
    fontSize: 11,
    color: Color(0xFF9CA3AF),
    fontWeight: FontWeight.w600,
  );

  // Tag chip text
  static const tagText = TextStyle(
    fontSize: 12,
    color: Color(0xFF5B667A),
    fontWeight: FontWeight.w600,
  );
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final PhoneKingNotificationModel _model = PhoneKingNotificationModelImpl();

  // Paging
  final int _pageSize = 10;
  int _page = 0;
  bool _hasNext = true;

  // UI state
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  // Data
  final List<NotificationContentVO> _items = [];

  @override
  void initState() {
    super.initState();
    _load(first: true);
  }

  int get _unreadCount => _items.where((e) => !e.read).length;

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
      final BaseResponse<NotificationVO> res = await _model.getAllNotification(
        _pageSize.toString(),
        _page.toString(),
      );
      final data = res.data;

      if (!mounted) return;
      if (data == null) {
        setState(() {
          _hasNext = false;
        });
      } else {
        setState(() {
          _items.addAll(data.content);
          _hasNext = !data.last;
          _page += 1;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _refresh() async => _load(first: true);

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;

    // optimistic UI
    final backup = _items.map((e) => e).toList();
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        final n = _items[i];
        _items[i] = NotificationContentVO(
          id: n.id,
          title: n.title,
          body: n.body,
          routeId: n.routeId,
          notificationType: n.notificationType,
          localDateTime: n.localDateTime,
          read: true,
        );
      }
    });

    try {
      await _model.readAllNotification();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text('All marked as read')),
        );
      }
    } catch (e) {
      // revert on failure
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(backup);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _markOneAsRead(NotificationContentVO n, int index) async {
    if (n.read) return;

    // optimistic UI
    setState(() {
      _items[index] = NotificationContentVO(
        id: n.id,
        title: n.title,
        body: n.body,
        routeId: n.routeId,
        notificationType: n.notificationType,
        localDateTime: n.localDateTime,
        read: true,
      );
    });

    try {
      await _model.readNotificationByID(n.id);
    } catch (e) {
      // revert on failure
      if (!mounted) return;
      setState(() {
        _items[index] = NotificationContentVO(
          id: n.id,
          title: n.title,
          body: n.body,
          routeId: n.routeId,
          notificationType: n.notificationType,
          localDateTime: n.localDateTime,
          read: false,
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    // "3 unread notification"
    final unreadText = '$_unreadCount ${l10n.notificationUnreadNotification}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          l10n.notificationNotification,
          style: _NotificationTextStyles.appBarTitle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : () => _load(first: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Text(
                  unreadText,
                  style: _NotificationTextStyles.headerInfo,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _unreadCount == 0 ? null : _markAllAsRead,
                  child: Text(
                    l10n.notificationMarkAsAllRead,
                    style: _NotificationTextStyles.headerAction.copyWith(
                      color: _unreadCount == 0
                          ? Colors.grey
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_error != null && _error!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAEA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFC9C9)),
                ),
                child: Text(
                  _error!,
                  style: _NotificationTextStyles.errorText,
                ),
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _loading && _items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount:
                _items.length + (_loadingMore || _hasNext ? 1 : 0),
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  if (i >= _items.length) {
                    // Infinite loader trigger
                    if (_hasNext && !_loadingMore) {
                      // slight delay to allow frame to build
                      scheduleMicrotask(() => _load());
                    }
                    return _hasNext
                        ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : const SizedBox.shrink();
                  }

                  final n = _items[i];
                  return _NotificationCard(
                    id: n.id,
                    title: n.title,
                    body: n.body,
                    tag: n.notificationType,
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

  // Convert backend localDateTime string to a friendly "time ago".
  // Adjust parsing if your format differs from ISO-8601.
  String _timeAgo(String raw) {
    try {
      final dt = DateTime.parse(
        raw,
      ); // expects e.g. "2025-10-26T23:29:09.741973"
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      // Fallback to date (yyyy-mm-dd)
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    } catch (_) {
      return raw; // show raw if parse fails
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String tag;
  final String timeLabel;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.timeLabel,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isRead
        ? const Color(0xFFF3F6FF).withValues(alpha: .55)
        : const Color(0xFFE9F0FF);
    final border = isRead ? const Color(0xFFE5E7F1) : const Color(0xFFD6E2FF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // leading icon/avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7F1)),
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                AssetImageUtils.notificationIcon,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),

            // content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + time + unread dot
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: _NotificationTextStyles.cardTitle,
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: _NotificationTextStyles.cardTime,
                      ),
                      const SizedBox(width: 6),
                      if (!isRead) const _Dot(color: Color(0xFF2F56FF)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: _NotificationTextStyles.cardBody,
                  ),
                  const SizedBox(height: 10),
                  // tag chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEFF3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tag,
                      style: _NotificationTextStyles.tagText,
                    ),
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
