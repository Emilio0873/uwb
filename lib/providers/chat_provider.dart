import 'package:flutter/material.dart';
import '../services/mistral_service.dart';
import '../services/firebase_service.dart';

class ChatProvider with ChangeNotifier {
  final MistralService _mistralService = MistralService();
  final FirebaseService _firebaseService = FirebaseService();
  
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _currentChatId;

  List<Map<String, String>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentChatId => _currentChatId;

  ChatProvider() {
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    if (_messages.isEmpty) {
      _messages.add({
        'role': 'assistant',
        'content': 'Bonjour ! Je suis l\'assistant virtuel de l\'Université William Booth. Comment puis-je vous aider aujourd\'hui ?'
      });
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text, String role, String language) async {
    if (text.isEmpty) return;

    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) return;

      // Si c'est le début d'un nouveau chat, on le crée dans Firestore
      if (_currentChatId == null) {
        _currentChatId = await _firebaseService.createChat(userId, text);
      }

      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
      notifyListeners();

      // On sauvegarde immédiatement le message utilisateur
      await _firebaseService.updateChatMessages(_currentChatId!, _messages);

      final response = await _mistralService.sendMessage(text, role: role, language: language);

      _messages.add({'role': 'assistant', 'content': response});
      
      // On sauvegarde la réponse de l'IA
      await _firebaseService.updateChatMessages(_currentChatId!, _messages);
    } catch (e) {
      print('Error in sendMessage: $e');
      _messages.add({
        'role': 'assistant', 
        'content': 'Désolé, une erreur est survenue lors de l\'envoi du message.'
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void newChat() {
    _messages.clear();
    _currentChatId = null;
    _mistralService.clearHistory();
    _addInitialGreeting();
  }

  void loadChat(String chatId, List<dynamic> messages) {
    _messages.clear();
    _currentChatId = chatId;
    _mistralService.clearHistory();
    
    for (var msg in messages) {
      final mapMsg = Map<String, String>.from(msg);
      _messages.add(mapMsg);
      // On remplit aussi l'historique de Mistral pour garder le contexte
      _mistralService.conversationHistory.add(mapMsg);
    }
    
    notifyListeners();
  }
}
