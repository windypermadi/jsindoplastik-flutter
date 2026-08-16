import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/kasbon_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/stock_mutation_provider.dart';
import 'providers/sync_provider.dart';
import 'views/auth/login_view.dart';
import 'views/main/main_scaffold_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JSIndoplastikApp());
}

class JSIndoplastikApp extends StatelessWidget {
  const JSIndoplastikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => KasbonProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => StockMutationProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'JSIndoplastik POS',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.accent,
                background: AppColors.background,
              ),
              textTheme: GoogleFonts.plusJakartaSansTextTheme(
                Theme.of(context).textTheme,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                titleTextStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            home: auth.isAuthenticated
                ? const MainScaffoldView()
                : const LoginView(),
          );
        },
      ),
    );
  }
}
