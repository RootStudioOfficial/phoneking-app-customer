import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String body;
  final String tag; // e.g. "system"
  final String timeAgo; // e.g. "3d ago"
  bool isRead;

  NotificationItem({required this.title, required this.body, required this.tag, required this.timeAgo, this.isRead = false});
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotificationItem> _items = [
    NotificationItem(
      title: 'Welcome to Phone King!',
      body: 'Thanks for joining our member benefits app. Earned point with every purchase.',
      tag: 'system',
      timeAgo: '3d ago',
      isRead: false,
    ),
    NotificationItem(
      title: 'Welcome to Phone King!',
      body: 'Thanks for joining our member benefits app. Earned point with every purchase.',
      tag: 'system',
      timeAgo: '3d ago',
      isRead: true,
    ),
  ];

  int get _unreadCount => _items.where((e) => !e.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (final n in _items) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Column(
        children: [
          // header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Text('$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}', style: TextStyle(color: Colors.grey.shade700)),
                const Spacer(),
                GestureDetector(
                  onTap: _unreadCount == 0 ? null : _markAllAsRead,
                  child: Text(
                    'Mark all as read',
                    style: TextStyle(color: _unreadCount == 0 ? Colors.grey : const Color(0xFF0C34FF), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final n = _items[i];
                return _NotificationCard(
                  item: n,
                  onTap: () {
                    setState(() => n.isRead = true);
                    // TODO: navigate to detail if needed
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = item.isRead ? const Color(0xFFF3F6FF).withValues(alpha: .55) : const Color(0xFFE9F0FF);
    final border = item.isRead ? const Color(0xFFE5E7F1) : const Color(0xFFD6E2FF);

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
            // leading icon/avatar (placeholder gear)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7F1)),
              ),
              child: const Icon(Icons.settings, color: Color(0xFF7C8AA6)),
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
                          item.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
                        ),
                      ),
                      Text(
                        item.timeAgo,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      if (!item.isRead) const _Dot(color: Color(0xFF2F56FF)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.body, style: TextStyle(color: Colors.grey.shade700, height: 1.45)),
                  const SizedBox(height: 10),
                  // tag chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFEDEFF3), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      item.tag,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5B667A), fontWeight: FontWeight.w600),
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
