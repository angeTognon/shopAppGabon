
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:gabon_client_app/models/user_model.dart';
import 'package:gabon_client_app/screens/auth_screen.dart';
import 'package:gabon_client_app/screens/main_screen.dart';
import 'package:gabon_client_app/screens/onboarding_screen.dart';
import 'package:gabon_client_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loyalty App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF3B82F6),
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AppInitializer(),
    );
  }
}


class LoyaltyApp extends StatelessWidget {
  const LoyaltyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loyalty App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF3B82F6),
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  User? _user;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final cachedUser = await AuthService.getCurrentUser();

    // Si on a un utilisateur en cache, on refresh depuis l'API pour avoir le statut actuel
    User? user = cachedUser;
    if (cachedUser != null) {
      try {
        user = await AuthService.fetchUserById(cachedUser.id);
        print('++++++User status from API: ${user.status ?? 'null'}');
      } catch (e) {
        print('Erreur lors du refresh: $e');
        // En cas d'erreur, on garde l'utilisateur en cache
        user = cachedUser;
      }
    }

    setState(() {
      _hasSeenOnboarding = hasSeenOnboarding;
      _user = user;
      _isLoading = false;
    });
    
    // Démarrer le timer de vérification du statut si on a un utilisateur
    if (user != null) {
      _startStatusTimer();
    }
    
    // Debug: Print user status after initialization
    if (user != null) {
      print('User status: ${user.status ?? 'null'}');
    } else {
      print('No user found');
    }
  }

  void _startStatusTimer() {
    _statusTimer?.cancel(); // Annuler le timer précédent s'il existe
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkUserStatus();
    });
  }

  Future<void> _checkUserStatus() async {
    if (_user == null) return;
    
    try {
      final updatedUser = await AuthService.fetchUserById(_user!.id);
      final currentStatus = _user!.status ?? '';
      final newStatus = updatedUser.status ?? '';
      
      print('Status check - Current: $currentStatus, New: $newStatus');
      
      // Si le statut a changé, mettre à jour l'interface
      if (currentStatus != newStatus) {
        print('Status changed from $currentStatus to $newStatus');
        setState(() {
          _user = updatedUser;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3B82F6),
          ),
        ),
      );
    }

    if (!_hasSeenOnboarding) {
      return OnboardingScreen(
        onComplete: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_seen_onboarding', true);
          setState(() {
            _hasSeenOnboarding = true;
          });
        },
      );
    }

    if (_user == null) {
      return AuthScreen(
        onAuthSuccess: (user) {
          setState(() {
            _user = user;
          });
          // Démarrer le timer après connexion
          _startStatusTimer();
        },
      );
    }

    // Si le statut utilisateur n'est pas "1" (actif), afficher un message d'erreur
    if (_user != null && (_user!.status ?? '') != '1') {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 64, color: Color(0xFF3B82F6)),
                const SizedBox(height: 16),
                const Text(
                  "Votre compte n'est pas actif",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _user?.customMessage?.isNotEmpty == true
                      ? _user!.customMessage!
                      : "Veuillez contacter le support pour activer votre compte.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await AuthService.logout();
                    Phoenix.rebirth(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Se déconnecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MainScreen(user: _user!);
  }
}