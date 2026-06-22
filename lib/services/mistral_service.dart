import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class MistralService {
  static const String _baseUrl = 'https://api.mistral.ai/v1/chat/completions';
  
  String _knowledgeBaseContent = "";
  List<Map<String, String>> conversationHistory = [];
  String _userRole = "etudiant";
  String _userName = "l'utilisateur";
  String _language = "Français";

  // System prompt to restrict answers based on role and knowledge base
  String get _systemPrompt => '''
Tu es un assistant universitaire intelligent pour l'Université William Booth. 
Ton rôle actuel est d'assister un utilisateur ayant le rôle suivant : $_userRole.
L'utilisateur s'appelle : $_userName.

IMPORTANT : Tu dois répondre EXCLUSIVEMENT en $_language.
Tu dois t'adresser à l'utilisateur par son nom ($_userName) de manière naturelle et polie quand c'est approprié.
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

  Future<void> initializeKnowledgeBase(String role, String language, {String? userName}) async {
    _userRole = role;
    _language = language;
    if (userName != null && userName.isNotEmpty) {
      _userName = userName;
    }
    
    // Normalisation du nom de dossier pour le rôle
    String roleFolder = role.toLowerCase().trim()
                             .replaceAll(' ', '_')
                             .replaceAll('é', 'e')
                             .replaceAll('ô', 'o');
    
    try {
      final presentation = await rootBundle.loadString('assets/knowledge_base/$roleFolder/presentation.txt');
      final frais = await rootBundle.loadString('assets/knowledge_base/$roleFolder/frais.txt');
      final calendrier = await rootBundle.loadString('assets/knowledge_base/$roleFolder/calendrier.txt');
      final specificProcedures = await rootBundle.loadString('assets/knowledge_base/$roleFolder/procedures.txt');
      
      _knowledgeBaseContent = """
=== PRESENTATION ===
$presentation

=== FRAIS ACADEMIQUES ===
$frais

=== CALENDRIER ===
$calendrier

=== PROCÉDURES SPÉCIFIQUES ($_userRole) ===
$specificProcedures
""";
      
      clearHistory(); 
    } catch (e) {
      print("Erreur de chargement de la base de connaissances pour $roleFolder: $e");
      // Fallback vers 'autres' si le dossier n'existe pas
      if (roleFolder != 'autres') {
        initializeKnowledgeBase('autres', language);
      } else {
        clearHistory();
      }
    }
  }

  Future<String> sendMessage(String message, {String role = "etudiant", String language = "Français", String? userName}) async {
    // S'assurer que le système est initialisé avec le bon rôle, la bonne langue et le bon nom
    if (conversationHistory.isEmpty || _userRole != role || _language != language || (userName != null && _userName != userName)) {
      await initializeKnowledgeBase(role, language, userName: userName);
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
        return "Une erreur technique s'est produite (code: ${response.statusCode}). Nos équipes ont été informées et travaillent à la résolution du problème.";
      }
    } catch (e) {
      return "Connexion interrompue. Veuillez vérifier votre accès à Internet et réessayer.";
    }
  }
  
  void clearHistory() {
    conversationHistory = [
      {'role': 'system', 'content': _systemPrompt}
    ];
  }
}
