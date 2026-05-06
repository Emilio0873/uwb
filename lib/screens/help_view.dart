import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appProvider.translate('help_support')),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : AppConstants.textPrimaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appProvider.translate('how_help'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
            ),
            const SizedBox(height: 24),
            _buildHelpCard(
              appProvider.translate('faq'),
              'Trouvez des réponses rapides aux questions courantes.',
              Icons.help_outline,
              isDark,
            ),
            _buildHelpCard(
              appProvider.translate('contact'),
              'Envoyez-nous un message pour une assistance personnalisée.',
              Icons.email,
              isDark,
            ),
            _buildHelpCard(
              appProvider.translate('guide'),
              'Apprenez à utiliser toutes les fonctionnalités du Chabot UWB.',
              Icons.book,
              isDark,
            ),
            const SizedBox(height: 32),
            const Text(
              'FAQ Populaire',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFaqItem('Comment réinitialiser mon mot de passe ?', isDark),
            _buildFaqItem('L\'assistant IA est-il disponible 24h/24 ?', isDark),
            _buildFaqItem('Comment puis-je voir mes notes ?', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(String title, String subtitle, IconData icon, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.grey[900] : Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.secondaryColor.withOpacity(0.1) : AppConstants.primaryColor.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(icon, color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildFaqItem(String question, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white, 
        borderRadius: BorderRadius.circular(12)
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Vous pouvez trouver cette information dans votre espace personnel ou en demandant directement à l\'assistant virtuel IA.',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
