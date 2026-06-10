import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/theme_provider.dart';
import '../../repositories/report_repository.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.name ?? 'Guest User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Sales Dashboard',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () =>
                ref.read(dashboardStatsProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(
                Formatters.initials(user?.name ?? '?'),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 10),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _confirmLogout(context, ref);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: statsAsync.when(
        loading: () => const _DashboardSkeleton(),
        error: (err, _) => _ErrorView(
          message: err.toString(),
          onRetry: () =>
              ref.read(dashboardStatsProvider.notifier).refresh(),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardStatsProvider.notifier).refresh(),
          child: _DashboardContent(stats: stats),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Content ────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Card: Total Revenue (Full width for visual emphasis)
          StatCard(
            title: 'Total Revenue',
            value: Formatters.currency(stats.totalRevenue),
            growth: stats.revenueGrowth,
            icon: Icons.attach_money_rounded,
            iconColor: AppTheme.primaryColor,
            iconBgColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),
          // Row: Total Customers and Total Sales
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Customers',
                  value: stats.totalCustomers.toString(),
                  growth: stats.customersGrowth,
                  icon: Icons.people_outline,
                  iconColor: AppTheme.successColor,
                  iconBgColor: AppTheme.successColor.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Total Sales',
                  value: stats.totalOrders.toString(),
                  growth: stats.ordersGrowth,
                  icon: Icons.shopping_bag_outlined,
                  iconColor: AppTheme.infoColor,
                  iconBgColor: AppTheme.infoColor.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Skeleton Loader ──────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Column(
        children: [
          const _SkeletonCard(height: 120),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkeletonCard(height: 100)),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonCard(height: 100)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
    );
  }
}

// ── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
