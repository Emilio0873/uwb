import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Auth Methods
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? faculte,
    String? promotion,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // Create profile record in Firestore
      await _firestore.collection('profiles').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'full_name': fullName,
        'role': role,
        'email': email,
        if (faculte != null) 'faculte': faculte,
        if (promotion != null) 'promotion': promotion,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  Future<DocumentSnapshot?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('profiles').doc(userId).get();
      return doc;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Chat Methods
  Future<String> createChat(String userId, String firstMessage) async {
    final doc = await _firestore.collection('chats').add({
      'userId': userId,
      'title': firstMessage.length > 30 ? '${firstMessage.substring(0, 30)}...' : firstMessage,
      'messages': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateChatMessages(String chatId, List<Map<String, String>> messages) async {
    await _firestore.collection('chats').doc(chatId).update({
      'messages': messages,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
