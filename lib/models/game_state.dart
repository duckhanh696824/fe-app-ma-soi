import 'player.dart';
import 'game_role.dart';

enum GamePhase {
  setup,
  roleReveal,
  night,
  nightAction,
  morning,
  day,
  voting,
  hunterShoot,
  gameOver,
}

class NightResult {
  final List<Player> killedPlayers;
  final List<String> events;

  NightResult({
    required this.killedPlayers,
    required this.events,
  });
}

class GameState {
  List<Player> players;
  Map<GameRole, int> roleConfig; // role -> count
  GamePhase phase;
  int nightCount;
  int currentNightRoleIndex;

  // Night actions
  String? wolfTargetId;
  String? guardProtectedId;
  String? lastGuardProtectedId;
  String? seerTargetId;
  bool? seerResult; // true = villager team
  bool witchHasHealPotion;
  bool witchHasKillPotion;
  bool witchUsedHeal;
  String? witchKillTargetId;

  // Day actions
  String? votedOutPlayerId;

  // Hunter
  String? hunterTargetId;

  // Results
  NightResult? lastNightResult;
  GameTeam? winner;

  GameState({
    this.players = const [],
    Map<GameRole, int>? roleConfig,
    this.phase = GamePhase.setup,
    this.nightCount = 0,
    this.currentNightRoleIndex = 0,
    this.wolfTargetId,
    this.guardProtectedId,
    this.lastGuardProtectedId,
    this.seerTargetId,
    this.seerResult,
    this.witchHasHealPotion = true,
    this.witchHasKillPotion = true,
    this.witchUsedHeal = false,
    this.witchKillTargetId,
    this.votedOutPlayerId,
    this.hunterTargetId,
    this.lastNightResult,
    this.winner,
  }) : roleConfig = roleConfig ?? {};
}
