import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';
import 'settings_view.dart';
import 'help_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProfile = appProvider.userProfile;
    
    final String fullName = appProvider.fullName ?? 'Utilisateur';
    final String email = appProvider.userProfile?['email'] ?? 'Non connecté';
    final String role = appProvider.userRole ?? 'Invité';

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/uwb.png',
                  height: 80,
                ),
                const SizedBox(height: 24),
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: AppConstants.primaryColor,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: AppConstants.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(
                color: Colors.brown, 
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileOption(
            context, 
            appProvider.translate('settings'), 
            Icons.settings_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsView())),
          ),
          _buildProfileOption(
            context, 
            appProvider.translate('help_support'), 
            Icons.help_outline,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpView())),
          ),
          const Divider(height: 32),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: Text(
              appProvider.translate('logout'),
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Provider.of<AppProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : AppConstants.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppConstants.primaryColor),
      ),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
        )
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
