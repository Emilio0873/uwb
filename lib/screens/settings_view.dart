import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appProvider.translate('settings')),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : AppConstants.textPrimaryColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle(appProvider.translate('appearance'), isDark),
          
          // Switch Thème Sombre
          _buildSwitchTile(
            appProvider.translate('dark_mode'),
            isDark ? 'Mode sombre activé' : 'Activer l\'interface sombre',
            Icons.dark_mode_outlined,
            appProvider.themeMode == ThemeMode.dark,
            (val) => appProvider.toggleTheme(val),
            isDark,
          ),

          const Divider(height: 32),
          
          // Sélecteur de Langue
          ListTile(
            leading: Icon(Icons.language, color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor),
            title: Text(appProvider.translate('system_lang')),
            subtitle: Text(appProvider.currentLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(appProvider, isDark),
          ),
          
          const Divider(height: 32),
          _buildSectionTitle(appProvider.translate('account'), isDark),
          ListTile(
            leading: Icon(Icons.lock_outline, color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor),
            title: const Text('Changer le mot de passe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Supprimer le compte', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Version 1.0.0 (Build 2024)',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged, bool isDark) {
    return SwitchListTile(
      secondary: Icon(icon, color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      activeColor: AppConstants.secondaryColor,
      value: value,
      onChanged: onChanged,
    );
  }

  void _showLanguagePicker(AppProvider appProvider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choisir la langue',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageItem(appProvider, 'Français', isDark),
              _buildLanguageItem(appProvider, 'English', isDark),
              _buildLanguageItem(appProvider, 'Lingala', isDark),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem(AppProvider appProvider, String language, bool isDark) {
    final isSelected = appProvider.currentLanguage == language;
    return ListTile(
      title: Text(
        language,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
              ? (isDark ? AppConstants.secondaryColor : AppConstants.primaryColor) 
              : (isDark ? Colors.white : Colors.black),
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor) : null,
      onTap: () {
        appProvider.setLanguage(language);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Langue changée en $language')),
        );
      },
    );
  }
}
