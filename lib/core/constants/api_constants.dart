class ApiConstants {
  // Use local backend for development (Android Emulator)
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String healthUrl = 'http://10.0.2.2:3000/health';

  static const String baseUrl='https://grocery-s4aj.onrender.com/api';
  static const String healthUrl = 'https://grocery-s4aj.onrender.com/health';

  static const Duration timeoutDuration = Duration(seconds: 15);
  
  // API endpoints
  static const String categoriesEndpoint = '/categories';
  static const String productsEndpoint = '/products';
  static const String bundlesEndpoint = '/bundles';
  static const String ordersEndpoint = '/orders';
  static const String searchEndpoint = '/products/search';
  static const String usersEndpoint = '/users';
} 