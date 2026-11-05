class AppConfig {
  /// Public order base URL (web / deep-link domain). Update per environment.
  static const publicOrderBaseUrl = 'https://escra.app/orders';

  /// Fallback backend public preview URL when web domain isn't ready.
  static const backendPublicOrderPreviewBase =
      'https://escra-payment-backend.onrender.com/api/v1/public/escrows/orders';
}
