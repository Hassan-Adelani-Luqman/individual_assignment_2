import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'providers/bookmarks_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'navigation/bottom_navigation.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

// AuthWrapper - Routes user based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading state while checking authentication
        if (authProvider.authState == AuthState.loading) {
          return const SplashScreen(message: 'Initializing...');
        }

        // User not authenticated - show login screen
        if (authProvider.authState == AuthState.unauthenticated) {
          // Clear bookmarks on logout
          Provider.of<BookmarksProvider>(context, listen: false).clear();
          return const LoginScreen();
        }

        // User needs email verification
        if (authProvider.authState == AuthState.needsVerification) {
          return const EmailVerificationScreen();
        }

        // User authenticated - show main app
        if (authProvider.authState == AuthState.authenticated) {
          // Initialize listeners for authenticated user
          if (authProvider.user != null) {
            Provider.of<ListingsProvider>(
              context,
              listen: false,
            ).initializeListingsListener();
            Provider.of<ListingsProvider>(
              context,
              listen: false,
            ).initializeUserListingsListener(authProvider.user!.uid);
            // Initialize bookmarks for this user
            Provider.of<BookmarksProvider>(
              context,
              listen: false,
            ).initialize(authProvider.user!.uid);
          }
          // Show main app with bottom navigation
          return const BottomNavigation();
        }

        // Fallback
        return const SplashScreen(message: 'Loading...');
      },
    );
  }
}

// Temporary splash screen - will be replaced with authentication flow
class SplashScreen extends StatelessWidget {
  final String message;

  const SplashScreen({super.key, this.message = 'Connecting to Firebase...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_city,
              size: 80,
              color: AppTheme.accentGold,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppTheme.accentGold),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
