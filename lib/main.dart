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
import 'core/providers/user_provider.dart';
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
            final provider = UserProvider();
            Future.microtask(() async {
              await provider.initializeUser();
            });
            return provider;
          },
        ),
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
        ChangeNotifierProxyProvider<UserProvider, NotificationProvider>(
          create: (context) => NotificationProvider(),
          update: (context, userProvider, notificationProvider) {
            if (notificationProvider != null) {
              
              Future.microtask(() async {
                await notificationProvider.setCurrentUser(userProvider.currentUser);
              });
            }
            return notificationProvider ?? NotificationProvider();
          },
        ),
        ChangeNotifierProxyProvider<UserProvider, CartProvider>(
          create: (context) => CartProvider(),
          update: (context, userProvider, cartProvider) {
            if (cartProvider != null) {
              
              Future.microtask(() async {
                await cartProvider.setCurrentUser(userProvider.currentUser);
              });
            }
            return cartProvider ?? CartProvider();
          },
        ),
        ChangeNotifierProxyProvider2<UserProvider, NotificationProvider, FavoriteProvider>(
          create: (context) => FavoriteProvider(),
          update: (context, userProvider, notificationProvider, favoriteProvider) {
            if (favoriteProvider != null) {
              
              Future.microtask(() async {
                await favoriteProvider.setCurrentUser(userProvider.currentUser);
                favoriteProvider.setNotificationProvider(notificationProvider);
              });
            }
            return favoriteProvider ?? FavoriteProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          
          String initialRoute = AppRoutes.onboarding;
          if (userProvider.isLoggedIn) {
            initialRoute = AppRoutes.entryPoint;
          }
          
          return MaterialApp(
            title: 'eGrocery',
            theme: AppTheme.defaultTheme,
            onGenerateRoute: RouteGenerator.onGenerate,
            initialRoute: initialRoute,
          );
        },
      ),
    );
  }
}
