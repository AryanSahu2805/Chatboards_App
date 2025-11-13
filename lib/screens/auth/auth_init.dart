import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

/// AuthInit listens for auth state changes and ensures a Firestore user
/// document exists for every authenticated Firebase user. If the user
/// document is missing it creates one using reasonable defaults gathered
/// from the FirebaseUser (email, displayName) and current time.
class AuthInit extends StatefulWidget {
  final Widget childIfSignedIn;
  const AuthInit({super.key, required this.childIfSignedIn});

  @override
  State<AuthInit> createState() => _AuthInitState();
}

class _AuthInitState extends State<AuthInit> {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<User?> get _authStream => FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          // Not signed in — let caller show login screen
          return const SizedBox.shrink();
        }

        // Ensure user document exists. We don't await here to avoid blocking UI,
        // but handle errors silently and log to console so it can be inspected.
        _ensureUserDocument(user);

        return widget.childIfSignedIn;
      },
    );
  }

  Future<void> _ensureUserDocument(User firebaseUser) async {
    try {
      final existing = await _firestoreService.getUser(firebaseUser.uid);
      if (existing != null) {
        // If the document exists but name fields are empty, try to patch them
        // from the FirebaseUser displayName.
        final Map<String, dynamic> updates = {};
        if ((existing.firstName == null || existing.firstName.isEmpty)) {
          final displayName = firebaseUser.displayName ?? '';
          final parts = displayName.trim().split(' ');
          if (parts.isNotEmpty && parts.first.isNotEmpty) {
            updates['firstName'] = parts.first;
          }
          if (parts.length > 1) {
            updates['lastName'] = parts.sublist(1).join(' ');
          }
          if (displayName.isNotEmpty) {
            updates['displayName'] = displayName;
          }
        } else if ((existing.displayName == null || existing.displayName!.isEmpty)) {
          final displayName = firebaseUser.displayName ?? '';
          if (displayName.isNotEmpty) updates['displayName'] = displayName;
        }

        if (updates.isNotEmpty) {
          await _firestoreService.updateUser(firebaseUser.uid, updates);
        }
        return;
      }

      final displayName = firebaseUser.displayName ?? '';
      final nameParts = displayName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        firstName: firstName,
        lastName: lastName,
        role: 'user',
        registrationDate: DateTime.now(),
        dateOfBirth: null,
        displayName: displayName.isEmpty ? null : displayName,
      );

      await _firestoreService.createUser(newUser);
      // created successfully
    } catch (e) {
      // Log the error; avoid crashing the UI. The user can still edit profile
      // later which will create/update the document.
      // ignore: avoid_print
      print('AuthInit: failed to ensure user document: $e');
    }
  }
}
