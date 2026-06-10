import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/customer_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/customer_tile.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Trigger pagination when near bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(customersProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text('${state.total}'),
              avatar: const Icon(Icons.people, size: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchFilterBar(searchController: _searchController),
          const Divider(height: 1),
          Expanded(
            child: _CustomerList(
              state: state,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ───────────────────────────────────────────────────────────────

class _SearchFilterBar extends ConsumerWidget {
  const _SearchFilterBar({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.pagePadding,
        12,
        AppConstants.pagePadding,
        12,
      ),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          ref.read(customersProvider.notifier).search(value);
        },
        onSubmitted: (value) {
          ref.read(customersProvider.notifier).search(value);
        },
        decoration: InputDecoration(
          hintText: 'Search customers...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    searchController.clear();
                    ref.read(customersProvider.notifier).search('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

// ── Customer List ────────────────────────────────────────────────────────────

class _CustomerList extends ConsumerWidget {
  const _CustomerList({
    required this.state,
    required this.scrollController,
  });

  final CustomersState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const _CustomerListSkeleton();
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(customersProvider.notifier).loadCustomers(),
              style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.customers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text('No customers found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(customersProvider.notifier).loadCustomers(refresh: true),
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.pagePadding,
          vertical: 8,
        ),
        itemCount: state.customers.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          if (index == state.customers.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return CustomerTile(customer: state.customers[index]);
        },
      ),
    );
  }
}

class _CustomerListSkeleton extends StatelessWidget {
  const _CustomerListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.pagePadding,
        vertical: 8,
      ),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (_, __) => Container(
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
      ),
    );
  }
}
