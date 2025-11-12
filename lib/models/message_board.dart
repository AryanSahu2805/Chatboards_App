class MessageBoard {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int colorValue;

  MessageBoard({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorValue,
  });

  // Static list of message boards (hardcoded as per requirements)
  static final List<MessageBoard> boards = [
    MessageBoard(
      id: 'games',
      name: 'Games',
      description: 'Discuss your favorite games',
      iconName: 'gamepad',
      colorValue: 0xFFFF5722, // Orange/Red
    ),
    MessageBoard(
      id: 'business',
      name: 'Business',
      description: 'Business and entrepreneurship',
      iconName: 'business',
      colorValue: 0xFF00BCD4, // Cyan
    ),
    MessageBoard(
      id: 'public_health',
      name: 'Public Health',
      description: 'Health and wellness discussions',
      iconName: 'health',
      colorValue: 0xFFE91E63, // Pink
    ),
    MessageBoard(
      id: 'study',
      name: 'Study',
      description: 'Academic discussions and study tips',
      iconName: 'school',
      colorValue: 0xFF9C27B0, // Purple
    ),
  ];
}