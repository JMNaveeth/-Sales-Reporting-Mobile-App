class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.cybermassolutions.com/v1';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String customersEndpoint = '/customers';
  static const String reportsEndpoint = '/reports';
  static const String dashboardEndpoint = '/dashboard/stats';

  // ── Pagination ───────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Animation Durations ──────────────────────────────────────────────────────
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 600);

  // ── Layout ───────────────────────────────────────────────────────────────────
  static const double pagePadding = 20.0;
  static const double cardRadius = 16.0;
  static const double smallRadius = 8.0;

  // ── Snackbar durations ───────────────────────────────────────────────────────
  static const Duration snackbarDuration = Duration(seconds: 3);
}
