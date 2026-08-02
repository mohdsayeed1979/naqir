import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/constants/app_durations.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_list_notifier.dart';
import 'package:naqirgiftbox/features/search/presentation/providers/search_providers.dart';
import 'package:naqirgiftbox/features/wishlist/presentation/providers/wishlist_providers.dart';
import 'package:naqirgiftbox/shared/widgets/cards/product_card.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _speech = SpeechToText();

  Timer? _debounce;
  String _submittedQuery = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(AppDurations.searchDebounce, () {
      if (value.trim().isEmpty) return;
      setState(() => _submittedQuery = value.trim());
      ref.read(searchHistoryProvider.notifier).addTerm(value.trim());
    });
  }

  void _selectTerm(String term) {
    _controller.text = term;
    setState(() => _submittedQuery = term);
    ref.read(searchHistoryProvider.notifier).addTerm(term);
  }

  Future<void> _toggleVoiceSearch() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    final available = await _speech.initialize();
    if (!available || !mounted) return;

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        if (result.finalResult) {
          _onQueryChanged(result.recognizedWords);
          setState(() => _isListening = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
          onSubmitted: (value) => _onQueryChanged(value),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none_rounded,
                color: _isListening ? theme.colorScheme.error : null,
              ),
              onPressed: _toggleVoiceSearch,
            ),
          ),
        ),
      ),
      body: _submittedQuery.isEmpty
          ? _SuggestionsView(history: history, onSelectTerm: _selectTerm)
          : _SearchResultsView(query: _submittedQuery),
    );
  }
}

class _SuggestionsView extends ConsumerWidget {
  const _SuggestionsView({required this.history, required this.onSelectTerm});

  final List<String> history;
  final ValueChanged<String> onSelectTerm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.searchRecent, style: theme.textTheme.titleSmall),
              TextButton(
                onPressed: () =>
                    ref.read(searchHistoryProvider.notifier).clear(),
                child: Text(l10n.searchClearHistory),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: history
                .map(
                  (term) => ActionChip(
                    label: Text(term),
                    onPressed: () => onSelectTerm(term),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(l10n.searchTrending, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: trendingSearches
              .map(
                (term) => ActionChip(
                  avatar: const Icon(Icons.trending_up_rounded, size: 16),
                  label: Text(term),
                  onPressed: () => onSelectTerm(term),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SearchResultsView extends ConsumerWidget {
  const _SearchResultsView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final searchQuery = ProductQuery(searchTerm: query);
    final state = ref.watch(productListProvider(searchQuery));
    final wishlist = ref.watch(wishlistProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.commonNoResultsFound,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.62,
      ),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final product = state.items[index];
        return ProductCard(
          product: product,
          isWishlisted: wishlist.contains(product.id),
          onTap: () => context.push(RoutePaths.productPath(product.id)),
          onToggleWishlist: () =>
              ref.read(wishlistProvider.notifier).toggle(product.id),
          onAddToCart: () {
            ref.read(cartProvider.notifier).addItem(product: product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} added to cart')),
            );
          },
        );
      },
    );
  }
}
