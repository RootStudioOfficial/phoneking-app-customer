import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/model/support/phone_king_support_model_impl.dart';
import 'package:phone_king_customer/data/vos/terms_and_condition_vo/terms_and_condition_vo.dart';

class TermsAndConditionPage extends StatefulWidget {
  const TermsAndConditionPage({super.key});

  @override
  State<TermsAndConditionPage> createState() => _TermsAndConditionPageState();
}

class _TermsAndConditionPageState extends State<TermsAndConditionPage> {
  final _supportModel = PhoneKingSupportModelImpl();

  bool _isLoading = false;
  String? _error;
  List<TermsAndConditionVO> _terms = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTerms());
  }

  Future<void> _loadTerms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await _supportModel.getSupportTermsAndConditions();
      if (!mounted) return;
      setState(() {
        _terms = res.data ?? const <TermsAndConditionVO>[];
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

  Future<void> _onRefresh() => _loadTerms();

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
              style: const TextStyle(color: Color(0xFFB00020), fontSize: 12),
            ),
          )
        : const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadTerms,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _terms.length + 1, // +1 to place error banner at top
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Error banner slot
                  return Align(
                    alignment: Alignment.topCenter,
                    child: errorBanner,
                  );
                }

                final term = _terms[index - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: .2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        color: Colors.black.withValues(alpha: .04),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        term.title ?? 'Untitled Section',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        term.description ?? 'No description available.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Empty state (when not loading, no error, and no terms)
          if (!_isLoading && _terms.isEmpty && !(_error?.isNotEmpty ?? false))
            Center(
              child: Text(
                'No terms and conditions available.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),

          // Loading overlay
          loadingOverlay,
        ],
      ),
    );
  }
}
