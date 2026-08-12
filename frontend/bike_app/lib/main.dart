import 'package:bike_app/providers/bike_provider.dart';
import 'package:bike_app/providers/dealer_provider.dart';
import 'package:bike_app/providers/journal_provider.dart';
import 'package:bike_app/screens/dealers/dealers_screen.dart';
import 'package:bike_app/providers/rental_provider.dart';
import 'package:bike_app/screens/journal/journal_screen.dart';
import 'package:bike_app/screens/rentals/rental_bike_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/bikes/bikes_category_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/story/our_story_screen.dart';
import 'state/auth_controller.dart';
import 'theme/theme.dart';

void main() {
  runApp(const AtelierApp());
}

class AtelierApp extends StatelessWidget {
  const AtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()..bootstrap()),
        ChangeNotifierProvider(create: (_) => BikeProvider()),
        ChangeNotifierProvider(create: (_) => DealerProvider()),
        ChangeNotifierProvider(create: (_) => RentalProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
      ],
      child: MaterialApp(
        title: 'Atelier',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AuthGate(),
        routes: {
          '/story': (_) => const OurStoryScreen(),
          '/bikes': (_) => const BikesScreen(),
          '/dealers': (_) => const DealerLocatorScreen(),
          '/rentals': (_) => const RentalBikeScreen(),
          '/journal': (_) => const JournalScreen(),
        },
        onUnknownRoute: (settings) {
          final title = settings.name?.replaceFirst('/', '') ?? 'Page';
          return MaterialPageRoute(
            builder: (_) => PlaceholderScreen(
              title: title.isEmpty
                  ? 'Coming soon'
                  : title[0].toUpperCase() + title.substring(1),
            ),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          backgroundColor: AppColors.ink,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.brass),
          ),
        );
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const AuthScreen();
    }
  }
}
