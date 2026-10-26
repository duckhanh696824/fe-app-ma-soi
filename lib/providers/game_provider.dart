import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_role.dart';
import '../models/game_state.dart';
import '../utils/game_logic.dart';

class GameProvider extends ChangeNotifier {
  GameState _state = GameState();

  GameState get state => _state;
  List<Player> get players => _state.players;
  GamePhase get phase => _state.phase;
  int get nightCount => _state.nightCount;
  GameTeam? get winner => _state.winner;
  NightResult? get lastNightResult => _state.lastNightResult;

  // ========== SETUP ==========

  void updateRoleConfig(GameRole role, int count) {
    _state.roleConfig[role] = count;
    if (count == 0) _state.roleConfig.remove(role);
    notifyListeners();
  }

  Map<GameRole, int> get roleConfig => _state.roleConfig;

  int get totalRolesConfigured =>
      _state.roleConfig.values.fold(0, (sum, c) => sum + c);

  String? validateConfig(int playerCount) {
    return GameLogic.validateRoleConfig(_state.roleConfig, playerCount);
  }

  void setupPlayers(List<String> names) {
    // Build role list based on config
    List<GameRole> roles = [];
    _state.roleConfig.forEach((role, count) {
      for (int i = 0; i < count; i++) {
        roles.add(role);
      }
    });

    // Shuffle roles
    roles.shuffle(Random());

    // Create players
    _state.players = List.generate(names.length, (i) {
      return Player(
        id: 'player_$i',
        name: names[i],
        role: roles[i],
      );
    });

    _state.phase = GamePhase.roleReveal;
    notifyListeners();
  }

  // ========== NIGHT PHASE ==========

  List<GameRole> get nightActionRoles =>
      GameLogic.getNightActionRoles(_state.players);

  GameRole? get currentNightRole {
    var roles = nightActionRoles;
    if (_state.currentNightRoleIndex < roles.length) {
      return roles[_state.currentNightRoleIndex];
    }
    return null;
  }

  List<Player> get alivePlayers => GameLogic.getAlivePlayers(_state.players);

  List<Player> alivePlayersExcluding(GameRole? role) =>
      GameLogic.getAlivePlayersExcludingRole(_state.players, role);

  void startNight() {
    _state.phase = GamePhase.night;
    _state.nightCount++;
    _state.currentNightRoleIndex = 0;
    _state.wolfTargetId = null;
    _state.guardProtectedId = null;
    _state.seerTargetId = null;
    _state.seerResult = null;
    _state.witchUsedHeal = false;
    _state.witchKillTargetId = null;
    notifyListeners();
  }

  void startNightActions() {
    _state.phase = GamePhase.nightAction;
    _state.currentNightRoleIndex = 0;
    notifyListeners();
  }

  // Wolf action
  void wolfAttack(String targetId) {
    _state.wolfTargetId = targetId;
    _advanceNightRole();
  }

  // Guard action
  void guardProtect(String targetId) {
    _state.guardProtectedId = targetId;
    _advanceNightRole();
  }

  String? get lastGuardProtectedId => _state.lastGuardProtectedId;

  // Seer action
  void seerReveal(String targetId) {
    _state.seerTargetId = targetId;
    Player? target = _state.players.where((p) => p.id == targetId).firstOrNull;
    if (target != null) {
      _state.seerResult = target.role.team == GameTeam.villager;
    }
    notifyListeners();
  }

  bool? get seerResult => _state.seerResult;
  String? get seerTargetId => _state.seerTargetId;

  void seerDone() {
    _advanceNightRole();
  }

  // Witch action
  bool get witchHasHealPotion => _state.witchHasHealPotion;
  bool get witchHasKillPotion => _state.witchHasKillPotion;
  String? get wolfTargetId => _state.wolfTargetId;

  Player? get wolfVictim {
    if (_state.wolfTargetId == null) return null;
    return _state.players
        .where((p) => p.id == _state.wolfTargetId)
        .firstOrNull;
  }

  void witchAction({bool useHeal = false, String? killTargetId}) {
    if (useHeal && _state.witchHasHealPotion) {
      _state.witchUsedHeal = true;
      _state.witchHasHealPotion = false;
    }
    if (killTargetId != null && _state.witchHasKillPotion) {
      _state.witchKillTargetId = killTargetId;
      _state.witchHasKillPotion = false;
    }
    _advanceNightRole();
  }

  void _advanceNightRole() {
    _state.currentNightRoleIndex++;
    if (_state.currentNightRoleIndex >= nightActionRoles.length) {
      _resolveNight();
    } else {
      notifyListeners();
    }
  }

  void _resolveNight() {
    NightResult result = GameLogic.calculateNightResult(
      players: _state.players,
      wolfTargetId: _state.wolfTargetId,
      guardProtectedId: _state.guardProtectedId,
      witchUsedHeal: _state.witchUsedHeal,
      witchKillTargetId: _state.witchKillTargetId,
    );

    // Apply deaths
    for (var dead in result.killedPlayers) {
      int idx = _state.players.indexWhere((p) => p.id == dead.id);
      if (idx != -1) {
        _state.players[idx].isAlive = false;
      }
    }

    // Save guard state for next night
    _state.lastGuardProtectedId = _state.guardProtectedId;

    _state.lastNightResult = result;

    // Check for hunter death
    bool hunterDied = result.killedPlayers.any((p) => p.role == GameRole.hunter);

    // Check win condition
    _state.winner = GameLogic.checkWinCondition(_state.players);

    if (_state.winner != null) {
      _state.phase = GamePhase.gameOver;
    } else if (hunterDied) {
      _state.phase = GamePhase.hunterShoot;
    } else {
      _state.phase = GamePhase.morning;
    }

    notifyListeners();
  }

  // ========== HUNTER ==========

  void hunterShoot(String targetId) {
    int idx = _state.players.indexWhere((p) => p.id == targetId);
    if (idx != -1) {
      _state.players[idx].isAlive = false;
    }
    _state.hunterTargetId = targetId;

    // Check win condition again
    _state.winner = GameLogic.checkWinCondition(_state.players);
    if (_state.winner != null) {
      _state.phase = GamePhase.gameOver;
    } else {
      _state.phase = GamePhase.morning;
    }
    notifyListeners();
  }

  // ========== DAY PHASE ==========

  void startDay() {
    _state.phase = GamePhase.day;
    _state.votedOutPlayerId = null;
    notifyListeners();
  }

  void startVoting() {
    _state.phase = GamePhase.voting;
    notifyListeners();
  }

  void voteOut(String? playerId) {
    if (playerId != null) {
      int idx = _state.players.indexWhere((p) => p.id == playerId);
      if (idx != -1) {
        _state.players[idx].isAlive = false;
        _state.votedOutPlayerId = playerId;

        // Check if voted out player is a hunter
        if (_state.players[idx].role == GameRole.hunter) {
          _state.phase = GamePhase.hunterShoot;
          notifyListeners();
          return;
        }
      }
    }

    // Check win condition
    _state.winner = GameLogic.checkWinCondition(_state.players);
    if (_state.winner != null) {
      _state.phase = GamePhase.gameOver;
    } else {
      // Go to next night
      startNight();
    }
    notifyListeners();
  }

  void skipVote() {
    // No one is voted out, go directly to night
    startNight();
  }

  // ========== RESET ==========

  void resetGame() {
    _state = GameState();
    notifyListeners();
  }

  void goToMorning() {
    _state.phase = GamePhase.morning;
    notifyListeners();
  }
}
