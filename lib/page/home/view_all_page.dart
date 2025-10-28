import 'package:flutter/material.dart';


class ViewAllPage extends StatefulWidget {
  const ViewAllPage({super.key});

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  String _brand = 'Gadget Plus';
  String _category = 'All Categories';

  final brands = const ['Gadget Plus', 'PhoneKing', 'KingPlus'];
  final categories = const ['All Categories', 'Accessories', 'Protection', 'Power'];

  final items = const [
    _Reward(brand: 'Gadget Plus', category: 'Protection', name: 'Screen Protector', pts: 1000),
    _Reward(brand: 'Gadget Plus', category: 'Accessories', name: 'Phone Case', pts: 1000),
    _Reward(brand: 'PhoneKing', category: 'Power', name: 'Charger', pts: 1200),
    _Reward(brand: 'KingPlus', category: 'Accessories', name: 'Earbuds', pts: 2000),
    _Reward(brand: 'Gadget Plus', category: 'Protection', name: 'Screen Protector', pts: 1000),
    _Reward(brand: 'Gadget Plus', category: 'Accessories', name: 'Phone Case', pts: 1000),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((r) {
      final brandOk = r.brand == _brand;
      final catOk = _category == 'All Categories' ? true : r.category == _category;
      return brandOk && catOk;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            title: const Text(''),
            leading: IconButton(
              icon: Icon(Icons.chevron_left,size: 22,),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner image
                  Placeholder(),
                  // Subtle gradient to make top icons readable
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterChipDropdown<String>(
                      value: _brand,
                      items: brands,
                      onChanged: (v) => setState(() => _brand = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterChipDropdown<String>(
                      value: _category,
                      items: categories,
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.86,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, i) => _RewardCard(item: filtered[i]),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Widgets & models ----

class _FilterChipDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _FilterChipDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isDense: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1133FF)),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: items
          .map((e) => DropdownMenuItem<T>(
        value: e,
        child: Text(
          e.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _Reward {
  final String brand;
  final String category;
  final String name;
  final int pts;
  const _Reward({
    required this.brand,
    required this.category,
    required this.name,
    required this.pts,
  });
}

class _RewardCard extends StatelessWidget {
  final _Reward item;
  const _RewardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder replaced with asset
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Placeholder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            '${_formatNumber(item.pts)} pts',
            style: const TextStyle(
              color: Color(0xFFFF6A00), // orange like mock
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
