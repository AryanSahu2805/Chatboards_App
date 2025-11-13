import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _boardsCollection => _firestore.collection('boards');
  
  // Create user document in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user document
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user document
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Get user stream (real-time updates)
  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      try {
        if (doc.exists) {
          return UserModel.fromSnapshot(doc);
        }
        return null;
      } catch (e) {
        // Return null if there's an error parsing the document
        return null;
      }
    });
  }

  // Send message to a board
  Future<void> sendMessage({
    required String boardId,
    required String message,
    required String userId,
    required String userName,
  }) async {
    try {
      await _boardsCollection.doc(boardId).collection('messages').add({
        'message': message,
        'userId': userId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages stream for a board (real-time)
  Stream<QuerySnapshot> getMessagesStream(String boardId) {
    return _boardsCollection
        .doc(boardId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Initialize message boards (call this once to set up boards)
  Future<void> initializeBoards() async {
    final boards = [
      {'id': 'games', 'name': 'Games', 'description': 'Discuss your favorite games'},
      {'id': 'business', 'name': 'Business', 'description': 'Business and entrepreneurship'},
      {'id': 'public_health', 'name': 'Public Health', 'description': 'Health and wellness discussions'},
      {'id': 'study', 'name': 'Study', 'description': 'Academic discussions and study tips'},
    ];

    for (var board in boards) {
      await _boardsCollection.doc(board['id']).set(board);
    }
  }
}