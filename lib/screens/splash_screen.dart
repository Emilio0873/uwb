import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.checkAuth();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    if (provider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using an icon as a placeholder for the University Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Image.asset(
                'assets/images/uwb.png',
                height: 80,
                width: 80,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Université William Booth',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plateforme Intelligente',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppConstants.secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 64),
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 30.0,
            ),
          ],
        ),
      ),
    );
  }
}
