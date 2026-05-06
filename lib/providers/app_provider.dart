import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AppProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;

  String _currentLanguage = 'Français';
  ThemeMode _themeMode = ThemeMode.light;

  String get currentLanguage => _currentLanguage;
  ThemeMode get themeMode => _themeMode;

  String translate(String key) {
    final translations = {
      'Français': {
        'assistant': 'Assistant Virtuel',
        'profile': 'Mon Profil',
        'search': 'Recherche de discussion...',
        'new_chat': 'Nouvelle discussion',
        'history': 'Anciennes discussions',
        'logout': 'Se déconnecter',
        'settings': 'Paramètres',
        'appearance': 'Apparence & Langue',
        'dark_mode': 'Mode Sombre',
        'system_lang': 'Langue du système',
        'account': 'Compte',
        'help_support': 'Aide & Support',
        'how_help': 'Comment pouvons-nous vous aider ?',
        'faq': 'Questions Fréquentes (FAQ)',
        'contact': 'Contacter le Support',
        'guide': 'Guide d\'Utilisation',
      },
      'English': {
        'assistant': 'Virtual Assistant',
        'profile': 'My Profile',
        'search': 'Search chat...',
        'new_chat': 'New Chat',
        'history': 'Past Conversations',
        'logout': 'Log Out',
        'settings': 'Settings',
        'appearance': 'Appearance & Language',
        'dark_mode': 'Dark Mode',
        'system_lang': 'System Language',
        'account': 'Account',
        'help_support': 'Help & Support',
        'how_help': 'How can we help you?',
        'faq': 'Frequently Asked Questions (FAQ)',
        'contact': 'Contact Support',
        'guide': 'User Guide',
      },
      'Lingala': {
        'assistant': 'Mosungi ya IA',
        'profile': 'Espace na ngai',
        'search': 'Luka lisolo...',
        'new_chat': 'Lisolo ya sika',
        'history': 'Masolo ya kala',
        'logout': 'Bima na compte',
        'settings': 'Bomeki',
        'appearance': 'Langi mpe Lokota',
        'dark_mode': 'Langi ya molili',
        'system_lang': 'Lokota ya mosungi',
        'account': 'Compte',
        'help_support': 'Lisungi mpe lisolo',
        'how_help': 'Tokoki kosunga yo ndenge nini?',
        'faq': 'Mituna oyo itunaka mingi',
        'contact': 'Solola na biso',
        'guide': 'Ndenge ya kosala',
      }
    };
    return translations[_currentLanguage]?[key] ?? key;
  }

  String? get userRole => _userProfile?['role'];
  String? get fullName => _userProfile?['full_name'];

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  bool get isAuthenticated {
    return _firebaseService.currentUser != null;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final doc = await _firebaseService.getProfile(user.uid);
      if (doc != null && doc.exists) {
        _userProfile = doc.data() as Map<String, dynamic>?;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        final credential = await _firebaseService.signIn(email, password);
        if (credential.user != null) {
          final doc = await _firebaseService.getProfile(credential.user!.uid);
          if (doc != null && doc.exists) {
            _userProfile = doc.data() as Map<String, dynamic>?;
          }
        }
        setLoading(false);
        notifyListeners();
        return true;
      }
      setLoading(false);
      return false;
    } catch (e) {
      print('Login error: $e');
      setLoading(false);
      return false;
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    setLoading(true);
    try {
      if (email.isNotEmpty && password.isNotEmpty && fullName.isNotEmpty) {
        await _firebaseService.signUp(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
        );
        setLoading(false);
        return null;
      }
      setLoading(false);
      return "Tous les champs sont obligatoires.";
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      return e.message;
    } catch (e) {
      setLoading(false);
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _firebaseService.signOut();
    _userProfile = null;
    notifyListeners();
  }
}
