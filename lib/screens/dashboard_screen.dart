import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import '../providers/chat_provider.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';
import 'chatbot_view.dart';
import 'profile_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Widget> _views = [
    const ChatbotView(),
    const ProfileView(),
  ];

  final List<String> _titles = [
    'assistant',
    'profile',
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: appProvider.themeMode == ThemeMode.dark ? Colors.black : AppConstants.backgroundColor,
      appBar: isDesktop
          ? null // Pas de AppBar sur Desktop, le menu est toujours visible
          : AppBar(
              title: Text(
                appProvider.translate(_titles[_currentIndex]),
                style: TextStyle(color: isDark ? AppConstants.secondaryColor : AppConstants.textPrimaryColor),
              ),
              backgroundColor: isDark ? Colors.black : Colors.white,
              foregroundColor: isDark ? AppConstants.secondaryColor : AppConstants.textPrimaryColor,
              elevation: 0,
              iconTheme: IconThemeData(color: isDark ? AppConstants.secondaryColor : AppConstants.textPrimaryColor),
            ),
      drawer: isDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 280,
              child: _buildDrawer(isDesktop: true),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _views,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer({bool isDesktop = false}) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userRole = appProvider.userRole ?? 'etudiant';
    final userName = appProvider.fullName ?? 'Assistant';

    final drawerContent = Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade100)),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: isDark ? Colors.white10 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/images/uwb.png',
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHABOT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor,
                          ),
                        ),
                        Text(
                          'U.W.B',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : AppConstants.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Bouton Nouvelle Discussion
                ElevatedButton.icon(
                  onPressed: () {
                    Provider.of<ChatProvider>(context, listen: false).newChat();
                    setState(() => _currentIndex = 0);
                    if (!isDesktop) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_comment_outlined),
                  label: Text(appProvider.translate('new_chat')),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor: AppConstants.secondaryColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // Recherche de discussion
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: appProvider.translate('search'),
                    prefixIcon: Icon(Icons.search, size: 20, color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Menu principal (Fonctionnalités)
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerItem(
                icon: Icons.chat_bubble_outline,
                title: appProvider.translate('assistant'),
                index: 0,
                isDesktop: isDesktop,
                appProvider: appProvider,
              ),
              
              const SizedBox(height: 24),
              
              // Anciennes discussions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  appProvider.translate('history'),
                  style: TextStyle(
                    color: isDark ? AppConstants.secondaryColor.withOpacity(0.7) : AppConstants.textSecondaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              
              // Historique réel depuis Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService().streamUserChats(FirebaseService().currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Erreur de chargement: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ));
                  }
                  
                  final allDocs = snapshot.data?.docs ?? [];
                  final docs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['title'] ?? '').toString().toLowerCase();
                    return title.contains(_searchQuery);
                  }).toList();

                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _searchQuery.isEmpty ? 'Aucune discussion récente' : 'Aucun résultat pour "$_searchQuery"',
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final String title = data['title'] ?? 'Discussion';
                      final List<dynamic> messages = data['messages'] ?? [];
                      final String chatId = docs[index].id;
                      final bool isActive = Provider.of<ChatProvider>(context).currentChatId == chatId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          tileColor: isActive 
                              ? (isDark ? AppConstants.secondaryColor.withOpacity(0.1) : AppConstants.primaryColor.withOpacity(0.05)) 
                              : null,
                          leading: Icon(
                            Icons.chat_outlined, 
                            size: 16, 
                            color: isActive 
                                ? (isDark ? AppConstants.secondaryColor : AppConstants.primaryColor) 
                                : Colors.grey
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              color: isActive 
                                  ? (isDark ? AppConstants.secondaryColor : AppConstants.primaryColor) 
                                  : (isDark ? Colors.white : AppConstants.textPrimaryColor),
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Provider.of<ChatProvider>(context, listen: false).loadChat(chatId, messages);
                            setState(() => _currentIndex = 0);
                            if (!isDesktop) Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        
        // Profil en bas
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppConstants.secondaryColor,
            child: Text(
              userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            appProvider.translate('profile'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            userName, 
            style: TextStyle(
              fontSize: 11, 
              color: isDark ? Colors.white60 : Colors.grey
            )
          ),
          onTap: () {
            setState(() => _currentIndex = 1);
            if (!isDesktop) Navigator.pop(context);
          },
        ),
        const SizedBox(height: 16),
      ],
    );

    if (isDesktop) {
      return Container(
        color: isDark ? Colors.black : const Color(0xFFF9FAFB),
        child: drawerContent,
      );
    } else {
      return Drawer(
        backgroundColor: isDark ? Colors.black : Colors.white,
        child: drawerContent,
      );
    }
  }

  Widget _buildRoleSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppConstants.secondaryColor : AppConstants.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon, 
    required String title, 
    required int index, 
    required bool isDesktop,
    required AppProvider appProvider,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected 
            ? (isDark ? AppConstants.secondaryColor.withOpacity(0.1) : AppConstants.primaryColor.withOpacity(0.08)) 
            : Colors.transparent,
        leading: Icon(
          icon, 
          color: isSelected 
              ? (isDark ? AppConstants.secondaryColor : AppConstants.primaryColor) 
              : AppConstants.textSecondaryColor,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? (isDark ? AppConstants.secondaryColor : AppConstants.primaryColor) 
                : (isDark ? Colors.white : AppConstants.textPrimaryColor),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () {
          setState(() => _currentIndex = index);
          if (!isDesktop) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildHistoryItem(String title, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: Colors.grey.withOpacity(0.1),
        leading: const Icon(Icons.chat_bubble_outline, size: 20, color: AppConstants.textSecondaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppConstants.textPrimaryColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          setState(() => _currentIndex = 0);
          if (!isDesktop) Navigator.pop(context);
        },
      ),
    );
  }
}
