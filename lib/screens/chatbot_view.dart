import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import '../providers/chat_provider.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final role = appProvider.userRole ?? 'etudiant';
    final language = appProvider.currentLanguage;

    _controller.clear();
    await chatProvider.sendMessage(text, role, language);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Watermark Logo
          Center(
            child: Opacity(
              opacity: isDark ? 0.08 : 0.05,
              child: Image.asset(
                'assets/images/uwb.png',
                width: 300,
              ),
            ),
          ),
          Column(
            children: [
              // Header / AppBar de remplacement
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  border: Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey.shade100)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      radius: 20,
                      child: Image.asset('assets/images/uwb.png', height: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assistant Virtuel UWB',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : AppConstants.textPrimaryColor,
                          ),
                        ),
                        const Text(
                          'Intelligence Artificielle',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConstants.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.security, size: 12, color: AppConstants.secondaryColor),
                          SizedBox(width: 4),
                          Text(
                            'Sécurisé',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppConstants.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    final isUser = message['role'] == 'user';
                    return _buildMessageBubble(message['content']!, isUser, isDark);
                  },
                ),
              ),
              if (chatProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: SpinKitThreeBounce(color: AppConstants.primaryColor, size: 20),
                ),
              _buildMessageInput(chatProvider, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              radius: 16,
              child: Image.asset('assets/images/uwb.png', height: 24),
            ),
            const SizedBox(width: 16),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? (isDark ? AppConstants.secondaryColor : const Color(0xFFF3F4F6)) 
                    : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isUser ? null : Border.all(color: isDark ? Colors.transparent : Colors.grey.shade100),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser 
                      ? (isDark ? Colors.black : AppConstants.textPrimaryColor) 
                      : (isDark ? Colors.white : AppConstants.textPrimaryColor),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 16),
            const CircleAvatar(
              backgroundColor: AppConstants.secondaryColor,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatProvider chatProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.grey[900]! : Colors.grey.shade100)),
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !chatProvider.isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Envoyer un message à l\'Assistant UWB...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  ),
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: chatProvider.isLoading ? null : _sendMessage,
                  icon: Icon(
                    Icons.send, 
                    color: chatProvider.isLoading ? Colors.grey : AppConstants.primaryColor
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
