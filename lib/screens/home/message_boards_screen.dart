import 'package:flutter/material.dart';
import '../../models/message_board.dart';
import '../../widgets/app_drawer.dart';
import '../chat/chat_screen.dart';

class MessageBoardsScreen extends StatelessWidget {
  const MessageBoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select A Room'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(), // Sliding navigation menu
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: MessageBoard.boards.length,
        itemBuilder: (context, index) {
          final board = MessageBoard.boards[index];
          return _BoardCard(board: board);
        },
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  final MessageBoard board;

  const _BoardCard({required this.board});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'gamepad':
        return Icons.games_outlined;
      case 'business':
        return Icons.business_center_outlined;
      case 'health':
        return Icons.local_hospital_outlined;
      case 'school':
        return Icons.school_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(board: board),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(board.colorValue),
                Color(board.colorValue).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(board.iconName),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        board.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        board.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}