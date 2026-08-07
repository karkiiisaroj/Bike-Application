import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_screen.dart';
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
    return ChangeNotifierProvider(
      create: (_) => AuthController()..bootstrap(),
      child: MaterialApp(
        title: 'Atelier',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AuthGate(),
        routes: {'/story': (_) => const OurStoryScreen()},
        // Any other tile (Bikes, Accessories, Rentals, etc.) isn't
        // registered yet — instead of crashing with "could not find a
        // generator for route," show a friendly placeholder until each
        // one is built out.
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
