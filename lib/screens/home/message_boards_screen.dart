import 'package:flutter/material.dart';
import 'dart:math' as Math;  // MOVED TO TOP
import '../../models/message_board.dart';
import '../../widgets/app_drawer.dart';
import '../chat/chat_screen.dart';

class MessageBoardsScreen extends StatelessWidget {
  const MessageBoardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Select A Room',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: MessageBoard.boards.length,
        itemBuilder: (context, index) {
          final board = MessageBoard.boards[index];
          return _ArtisticBoardCard(
            board: board,
            index: index,
          );
        },
      ),
    );
  }
}

class _ArtisticBoardCard extends StatelessWidget {
  final MessageBoard board;
  final int index;

  const _ArtisticBoardCard({
    required this.board,
    required this.index,
  });

  String _getImagePath(String boardId) {
    // Handle different possible image names
    switch (boardId) {
      case 'games':
        return 'assets/images/games.png';
      case 'business':
        return 'assets/images/business.png';
      case 'public_health':
        return 'assets/images/health.png'; // Maps to health.png
      case 'study':
        return 'assets/images/study.png';
      default:
        return 'assets/images/$boardId.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(board.colorValue);
    final isTextOnLeft = index.isEven;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(board: board),
            ),
          );
        },
        child: Stack(
          children: [
            // Background with gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Decorative circles - Multiple layers
            _DecorativeCircles(color: primaryColor),

            // Wave pattern overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _WavePainter(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Content Row
            Row(
              children: [
                // Text side (40% width)
                if (isTextOnLeft)
                  _TextSection(
                    board: board,
                    isLeft: true,
                    width: screenWidth * 0.4,
                  ),

                // Image side (60% width)
                _ImageSection(
                  board: board,
                  imagePath: _getImagePath(board.id),
                  isLeft: !isTextOnLeft,
                  width: screenWidth * 0.6,
                  primaryColor: primaryColor,
                ),

                // Text on right
                if (!isTextOnLeft)
                  _TextSection(
                    board: board,
                    isLeft: false,
                    width: screenWidth * 0.4,
                  ),
              ],
            ),

            // Floating decorative elements
            _FloatingDecorations(boardId: board.id),
          ],
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final MessageBoard board;
  final bool isLeft;
  final double width;

  const _TextSection({
    required this.board,
    required this.isLeft,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: isLeft ? 24 : 20,
        vertical: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Title - FIXED: Single line, no wrapping
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              board.name,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final MessageBoard board;
  final String imagePath;
  final bool isLeft;
  final double width;
  final Color primaryColor;

  const _ImageSection({
    required this.board,
    required this.imagePath,
    required this.isLeft,
    required this.width,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Glow effect behind image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // Image with rounded border
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback with better icon
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getIcon(board.iconName),
                        size: 100,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'gamepad':
        return Icons.sports_esports_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'school':
        return Icons.school_rounded;
      default:
        return Icons.chat_bubble_rounded;
    }
  }
}

class _DecorativeCircles extends StatelessWidget {
  final Color color;

  const _DecorativeCircles({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top right large circle
        Positioned(
          right: -80,
          top: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        
        // Bottom left large circle
        Positioned(
          left: -60,
          bottom: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),

        // Top left small circle
        Positioned(
          left: 40,
          top: 30,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
        ),

        // Bottom right medium circle
        Positioned(
          right: 60,
          bottom: 40,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingDecorations extends StatelessWidget {
  final String boardId;

  const _FloatingDecorations({required this.boardId});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _getDecorationsForBoard(boardId),
    );
  }

  List<Widget> _getDecorationsForBoard(String boardId) {
    switch (boardId) {
      case 'games':
        return [
          _FloatingIcon(
            icon: Icons.stars,
            top: 30,
            right: 80,
            size: 30,
          ),
          _FloatingIcon(
            icon: Icons.emoji_events,
            bottom: 40,
            left: 70,
            size: 35,
          ),
        ];
      case 'business':
        return [
          _FloatingIcon(
            icon: Icons.trending_up,
            top: 40,
            left: 60,
            size: 32,
          ),
          _FloatingIcon(
            icon: Icons.attach_money,
            bottom: 50,
            right: 90,
            size: 28,
          ),
        ];
      case 'public_health':
        return [
          _FloatingIcon(
            icon: Icons.favorite,
            top: 35,
            right: 70,
            size: 30,
          ),
          _FloatingIcon(
            icon: Icons.healing,
            bottom: 45,
            left: 80,
            size: 32,
          ),
        ];
      case 'study':
        return [
          _FloatingIcon(
            icon: Icons.lightbulb,
            top: 40,
            left: 70,
            size: 32,
          ),
          _FloatingIcon(
            icon: Icons.auto_stories,
            bottom: 50,
            right: 80,
            size: 30,
          ),
        ];
      default:
        return [];
    }
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;

  const _FloatingIcon({
    required this.icon,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(
        icon,
        size: size,
        color: Colors.white.withOpacity(0.25),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create wave pattern
    path.moveTo(0, size.height * 0.7);
    
    for (double i = 0; i < size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.7 + 20 * Math.sin((i / size.width) * 2 * Math.pi * 3),
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}