import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonaa/view/sceens/OnboardingScreen.dart';
import 'package:sonaa/view/sceens/auth/login_screen.dart';
import 'package:sonaa/view/sceens/home_screen/home_screen.dart';
import 'package:sonaa/view/sceens/search_screen/SearchScreen.dart';
import 'package:sonaa/view/sceens/splashscreen.dart';
import 'package:sonaa/view_model/Add_ad_new/ad_cubit.dart';
import 'package:sonaa/view_model/favorites_cuibt/favorites_cubit.dart';
import 'package:sonaa/view_model/home_cubit/home_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/repositories/add_ad_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/home_repository.dart';
import 'view_model/auth_cubit/auth_cubit.dart';

// ============================================
// Supabase Configuration
// ============================================
class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: "https://hxpjiuqtwwyikemuuyzn.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh4cGppdXF0d3d5aWtlbXV1eXpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNTQ3NjEsImV4cCI6MjA3NTgzMDc2MX0.FC-dsJQIPBfRmte-KxoOF_ko5f0kXk4XQ6As_XnoTN8",
      authOptions: const FlutterAuthClientOptions(
        // لازم نفس الredirect اللي ضفته في Supabase
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

// ============================================
// Main Function
// ============================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  await SupabaseConfig.initialize();

  runApp(const SonaaApp());
}

// ============================================
// Main App
// ============================================
class SonaaApp extends StatelessWidget {
  const SonaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // إنشاء Repository مرة واحدة
    final authRepository = AuthRepository(SupabaseConfig.client);
    final supabaseRepository = SupabaseRepository();
    final homeRepository = HomeRepository();

    return RepositoryProvider.value(
      value: authRepository,
      child: MultiBlocProvider(
        // إنشاء AuthCubit مرة واحدة للتطبيق كله
        providers: [
          BlocProvider(
            create: (_) => AuthCubit(authRepository: authRepository),
          ),
          BlocProvider(
          create: (context) => AddAdViewModel(repo: supabaseRepository),
          ), BlocProvider(
          create: (context) => HomeCubit(repository: homeRepository),
          ),
    BlocProvider(
    create: (context) => FavoritesCubit(
    repository: FavoritesRepository(),
    )..loadFavorites(),
    ),
        ],
        child: MaterialApp(
          title: 'SONAA Global Ads',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF0077B6),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: const MaterialColor(0xFF0077B6, {
                50: Color(0xFFE0F7FA),
                100: Color(0xFFB3E5FC),
                200: Color(0xFF81D4FA),
                300: Color(0xFF4FC3F7),
                400: Color(0xFF29B6F6),
                500: Color(0xFF0077B6),
                600: Color(0xFF039BE5),
                700: Color(0xFF0288D1),
                800: Color(0xFF0277BD),
                900: Color(0xFF01579B),
              }),
            ).copyWith(
              secondary: const Color(0xFFFFC300),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(), // Future screens
            '/search': (context) => const SearchScreen(),

          },
        ),
      ),
    );
  }
}
