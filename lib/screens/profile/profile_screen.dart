import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestoreService.updateUser(user.uid, {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'displayName': _displayNameController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isEditing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Please log in to view your profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: _firestoreService.getUserStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No user data found'));
          }

          final userData = snapshot.data!;

          if (!_isEditing) {
            _firstNameController.text = userData.firstName;
            _lastNameController.text = userData.lastName;
            _displayNameController.text = userData.displayName ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                // Email (Read-only)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(userData.email),
                  ),
                ),
                const SizedBox(height: 8),

                // First Name
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: _isEditing
                        ? TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: InputBorder.none,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('First Name',
                                  style: TextStyle(fontSize: 12)),
                              Text(userData.firstName),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Last Name
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: _isEditing
                        ? TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: InputBorder.none,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Last Name',
                                  style: TextStyle(fontSize: 12)),
                              Text(userData.lastName),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Display Name
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: _isEditing
                        ? TextField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              border: InputBorder.none,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Display Name',
                                  style: TextStyle(fontSize: 12)),
                              Text(userData.displayName ?? 'Not set'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Role (Read-only)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: const Text('Role', style: TextStyle(fontSize: 12)),
                    subtitle: Text(userData.role.toUpperCase()),
                  ),
                ),
                const SizedBox(height: 8),

                // Registration Date (Read-only)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Member Since',
                        style: TextStyle(fontSize: 12)),
                    subtitle: Text(
                      '${userData.registrationDate.day}/${userData.registrationDate.month}/${userData.registrationDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save/Cancel buttons
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}