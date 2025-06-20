import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/routes/on_generate_route.dart';
import 'core/themes/app_themes.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/favorite_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database connection
  try {
    await DatabaseService.instance.connect();
    debugPrint('Database connection successful');
  } catch (e) {
    debugPrint('Database connection failed, using mock data: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final provider = AppProvider();
            // Delay data initialization until UI is built
            Future.microtask(() async {
              await provider.initializeData();
            });
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(), // Constructor automatically loads cart data
        ),
        ChangeNotifierProvider(
          create: (context) => FavoriteProvider(), // Constructor automatically loads favorite data
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'eGrocery',
        theme: AppTheme.defaultTheme,
        onGenerateRoute: RouteGenerator.onGenerate,
        initialRoute: AppRoutes.onboarding,
      ),
    );
  }
}
