class ApiConstants {
  // Always use Render backend for both development and production
  static const String baseUrl = 'https://grocery-store-flutter-app.onrender.com/api';
  static const String healthUrl = 'https://grocery-store-flutter-app.onrender.com/health';
  
  // Backup local URLs (commented out, can be restored if needed)
  // static const String _localBaseUrl = 'http://10.0.2.2:3000/api';
  // static const String _localHealthUrl = 'http://10.0.2.2:3000/health';
  
  // Request configuration
  static const Duration timeoutDuration = Duration(seconds: 15);
  
  // API endpoints
  static const String categoriesEndpoint = '/categories';
  static const String productsEndpoint = '/products';
  static const String bundlesEndpoint = '/bundles';
  static const String ordersEndpoint = '/orders';
  static const String searchEndpoint = '/products/search';
} 