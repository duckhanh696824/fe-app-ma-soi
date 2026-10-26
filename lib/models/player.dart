import 'game_role.dart';

class Player {
  final String id;
  final String name;
  final GameRole role;
  bool isAlive;
  bool isProtected;
  String? lastProtectedById; // Guard can't protect same person 2 nights in a row

  Player({
    required this.id,
    required this.name,
    required this.role,
    this.isAlive = true,
    this.isProtected = false,
    this.lastProtectedById,
  });

  Player copyWith({
    String? id,
    String? name,
    GameRole? role,
    bool? isAlive,
    bool? isProtected,
    String? lastProtectedById,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      isProtected: isProtected ?? this.isProtected,
      lastProtectedById: lastProtectedById ?? this.lastProtectedById,
    );
  }
}
