import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedRole = 'etudiant';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _roles = [
    'etudiant',
    'rectorat',
    'service académique',
    'decanat',
    'agent inscription',
    'agent finance',
    'agent contrôle de dossier',
    'autres',
  ];

  final List<String> _faculties = [
    'Médecine',
    'Droit',
    'Économie',
    'Théologie',
    'Informatique',
    'SIC',
    'ISTM',
  ];

  final List<String> _promotions = [
    'B1', 'B2', 'B3',
    'L1', 'L2', 'L3',
    'D1', 'D2', 'D3', 'D4',
    'M1', 'M2',
  ];

  String? _selectedFaculte;
  String? _selectedPromotion;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      if (_isLogin) {
        final success = await provider.login(
          _emailController.text,
          _passwordController.text,
        );

        if (success && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible de se connecter. Veuillez vérifier votre email et votre mot de passe.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Les mots de passe ne correspondent pas.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final error = await provider.register(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          role: _selectedRole,
          faculte: _selectedRole == 'etudiant' ? _selectedFaculte : null,
          promotion: _selectedRole == 'etudiant' ? _selectedPromotion : null,
        );

        if (error == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compte créé avec succès ! Vous pouvez maintenant vous connecter.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _isLogin = true;
          });
        } else if (mounted) {
          String errorMessage = error ?? "Une erreur inattendue est survenue";
          if (errorMessage.contains("User already registered")) {
            errorMessage = "Cette adresse email est déjà associée à un compte.";
          } else if (errorMessage.contains("Password should be")) {
            errorMessage = "Par sécurité, le mot de passe doit comporter au moins 6 caractères.";
          } else if (errorMessage.contains("invalid-email")) {
            errorMessage = "Veuillez entrer une adresse email valide.";
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AppProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/uwb.png',
                  height: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? 'Bienvenue' : 'Créer un compte',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                    ? 'Connectez-vous pour accéder à vos services'
                    : 'Remplissez les informations pour vous inscrire',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom complet',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => 
                            (!_isLogin && (value == null || value.isEmpty)) 
                              ? 'Veuillez entrer votre nom complet' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Rôle / Fonction',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role[0].toUpperCase() + role.substring(1)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                        if (_selectedRole == 'etudiant') ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedFaculte,
                            decoration: const InputDecoration(
                              labelText: 'Faculté',
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                            items: _faculties.map((faculte) {
                              return DropdownMenuItem(
                                value: faculte,
                                child: Text(faculte),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFaculte = value;
                              });
                            },
                            validator: (value) => 
                              (!_isLogin && _selectedRole == 'etudiant' && (value == null || value.isEmpty)) 
                                ? 'Veuillez sélectionner votre faculté' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedPromotion,
                            decoration: const InputDecoration(
                              labelText: 'Promotion',
                              prefixIcon: Icon(Icons.trending_up),
                            ),
                            items: _promotions.map((promotion) {
                              return DropdownMenuItem(
                                value: promotion,
                                child: Text(promotion),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPromotion = value;
                              });
                            },
                            validator: (value) => 
                              (!_isLogin && _selectedRole == 'etudiant' && (value == null || value.isEmpty)) 
                                ? 'Veuillez sélectionner votre promotion' : null,
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty ? 'Veuillez entrer votre email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre mot de passe' : null,
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (!_isLogin) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez confirmer votre mot de passe';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(_isLogin ? 'Se connecter' : 'S\'inscrire'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: isLoading ? null : () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin 
                            ? 'Pas encore de compte ? S\'inscrire'
                            : 'Déjà un compte ? Se connecter',
                          style: const TextStyle(color: AppConstants.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
