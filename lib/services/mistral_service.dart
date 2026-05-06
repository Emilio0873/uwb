import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class MistralService {
  static const String _baseUrl = 'https://api.mistral.ai/v1/chat/completions';
  
  String _knowledgeBaseContent = "";
  List<Map<String, String>> conversationHistory = [];
  String _userRole = "etudiant";
  String _language = "Français";

  // System prompt to restrict answers based on role and knowledge base
  String get _systemPrompt => '''
Tu es un assistant universitaire intelligent pour l'Université William Booth. 
Ton rôle actuel est d'assister un utilisateur ayant le rôle suivant : $_userRole.

IMPORTANT : Tu dois répondre EXCLUSIVEMENT en $_language.
Si l'utilisateur change la langue du système, tes prochaines réponses doivent être en $_language.

INSTRUCTIONS CRUCIALES :
1. Tu dois te baser EXCLUSIVEMENT sur les documents fournis ci-dessous. 
2. Tu dois filtrer tes réponses selon le rôle de l'utilisateur :
   - Si l'utilisateur est un "etudiant", réponds uniquement aux questions concernant la vie étudiante, les frais, et le calendrier.
   - Si l'utilisateur est un "agent inscription", concentre-toi sur les procédures d'inscription et les dossiers.
3. Si la question dépasse les prérogatives du rôle de l'utilisateur ou si l'information ne se trouve PAS dans ces documents, réponds (en $_language) que vous n'avez pas cette information pour son rôle.
4. Tu ne dois pas inventer d'informations.

DOCUMENTS OFFICIELS :
$_knowledgeBaseContent
''';

  Future<void> initializeKnowledgeBase(String role, String language) async {
    _userRole = role;
    _language = language;
    try {
      final presentation = await rootBundle.loadString('assets/knowledge_base/presentation.txt');
      final frais = await rootBundle.loadString('assets/knowledge_base/frais.txt');
      final calendrier = await rootBundle.loadString('assets/knowledge_base/calendrier.txt');
      final roles = await rootBundle.loadString('assets/knowledge_base/roles_procedures.txt');
      
      _knowledgeBaseContent = """
=== PRESENTATION ===
$presentation

=== FRAIS ACADEMIQUES ===
$frais

=== CALENDRIER ===
$calendrier

=== PROCÉDURES ET RÔLES ===
$roles
""";
      
      clearHistory(); 
    } catch (e) {
      print("Erreur de chargement de la base de connaissances : $e");
      clearHistory();
    }
  }

  Future<String> sendMessage(String message, {String role = "etudiant", String language = "Français"}) async {
    // S'assurer que le système est initialisé avec le bon rôle et la bonne langue
    if (conversationHistory.isEmpty || _userRole != role || _language != language) {
      await initializeKnowledgeBase(role, language);
    }

    conversationHistory.add({'role': 'user', 'content': message});

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.mistralApiKey}',
        },
        body: jsonEncode({
          'model': 'mistral-small-latest',
          'messages': conversationHistory,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = data['choices'][0]['message']['content'];
        conversationHistory.add({'role': 'assistant', 'content': reply});
        return reply;
      } else {
        return "Désolé, je rencontre des difficultés techniques. Code d'erreur : ${response.statusCode}";
      }
    } catch (e) {
      return "Une erreur de connexion est survenue. Veuillez vérifier votre connexion internet.";
    }
  }
  
  void clearHistory() {
    conversationHistory = [
      {'role': 'system', 'content': _systemPrompt}
    ];
  }
}
