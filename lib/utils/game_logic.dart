import '../models/player.dart';
import '../models/game_role.dart';
import '../models/game_state.dart';

class GameLogic {
  /// Calculate who dies after a night phase
  static NightResult calculateNightResult({
    required List<Player> players,
    required String? wolfTargetId,
    required String? guardProtectedId,
    required bool witchUsedHeal,
    required String? witchKillTargetId,
  }) {
    List<Player> killed = [];
    List<String> events = [];

    // Wolf attack
    if (wolfTargetId != null) {
      bool isProtected = wolfTargetId == guardProtectedId;
      bool isHealed = witchUsedHeal;

      if (isProtected) {
        events.add('Bảo vệ đã cứu người bị sói cắn!');
      } else if (isHealed) {
        events.add('Phù thủy đã dùng bình cứu!');
      } else {
        Player? victim =
            players.where((p) => p.id == wolfTargetId && p.isAlive).firstOrNull;
        if (victim != null) {
          killed.add(victim);
          events.add('${victim.name} đã bị sói cắn chết!');
        }
      }
    }

    // Witch kill
    if (witchKillTargetId != null) {
      Player? witchVictim = players
          .where((p) => p.id == witchKillTargetId && p.isAlive)
          .firstOrNull;
      if (witchVictim != null && !killed.contains(witchVictim)) {
        killed.add(witchVictim);
        events.add('${witchVictim.name} đã bị đầu độc!');
      }
    }

    if (killed.isEmpty) {
      events.add('Đêm qua không ai bị giết!');
    }

    return NightResult(killedPlayers: killed, events: events);
  }

  /// Check if game is over and return winner
  static GameTeam? checkWinCondition(List<Player> players) {
    int aliveWolves =
        players.where((p) => p.isAlive && p.role == GameRole.werewolf).length;
    int aliveVillagers =
        players.where((p) => p.isAlive && p.role != GameRole.werewolf).length;

    if (aliveWolves == 0) {
      return GameTeam.villager;
    }
    if (aliveWolves >= aliveVillagers) {
      return GameTeam.wolf;
    }
    return null;
  }

  /// Get roles that have night actions, sorted by order
  static List<GameRole> getNightActionRoles(List<Player> players) {
    Set<GameRole> activeRoles = players
        .where((p) => p.isAlive && p.role.hasNightAction)
        .map((p) => p.role)
        .toSet();

    List<GameRole> sorted = activeRoles.toList()
      ..sort((a, b) => a.nightOrder.compareTo(b.nightOrder));

    return sorted;
  }

  /// Get alive players excluding a specific role
  static List<Player> getAlivePlayersExcludingRole(
      List<Player> players, GameRole? excludeRole) {
    return players
        .where((p) => p.isAlive && (excludeRole == null || p.role != excludeRole))
        .toList();
  }

  /// Get alive players
  static List<Player> getAlivePlayers(List<Player> players) {
    return players.where((p) => p.isAlive).toList();
  }

  /// Validate role configuration
  static String? validateRoleConfig(
      Map<GameRole, int> roleConfig, int totalPlayers) {
    int totalRoles = roleConfig.values.fold(0, (sum, count) => sum + count);

    if (totalRoles != totalPlayers) {
      return 'Tổng số vai ($totalRoles) phải bằng số người chơi ($totalPlayers)';
    }

    int wolfCount = roleConfig[GameRole.werewolf] ?? 0;
    if (wolfCount == 0) {
      return 'Phải có ít nhất 1 Ma Sói';
    }

    int villagerTeamCount = totalRoles - wolfCount;
    if (villagerTeamCount <= wolfCount) {
      return 'Số dân phải nhiều hơn số sói';
    }

    // Unique roles can only have 0 or 1
    for (var role in [GameRole.seer, GameRole.guard, GameRole.witch, GameRole.hunter]) {
      if ((roleConfig[role] ?? 0) > 1) {
        return '${role.displayName} chỉ có thể có tối đa 1 người';
      }
    }

    return null;
  }
}
