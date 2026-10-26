import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Phe trong game Ma Sói
enum GameTeam {
  villager,   // Phe Dân Làng
  wolf,       // Phe Sói
  switchSide, // Đổi Phe
  thirdParty, // Phe Thứ 3
}

extension GameTeamExtension on GameTeam {
  String get displayName {
    switch (this) {
      case GameTeam.villager:
        return 'Phe Dân Làng';
      case GameTeam.wolf:
        return 'Phe Sói';
      case GameTeam.switchSide:
        return 'Đổi Phe';
      case GameTeam.thirdParty:
        return 'Phe Thứ 3';
    }
  }

  String get emoji {
    switch (this) {
      case GameTeam.villager:
        return '🏘️';
      case GameTeam.wolf:
        return '🐺';
      case GameTeam.switchSide:
        return '🔄';
      case GameTeam.thirdParty:
        return '⚖️';
    }
  }

  Color get color {
    switch (this) {
      case GameTeam.villager:
        return AppColors.factionVillager;
      case GameTeam.wolf:
        return AppColors.factionWolf;
      case GameTeam.switchSide:
        return AppColors.factionSwitch;
      case GameTeam.thirdParty:
        return AppColors.factionThird;
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case GameTeam.villager:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case GameTeam.wolf:
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
        );
      case GameTeam.switchSide:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case GameTeam.thirdParty:
        return const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
        );
    }
  }
}

/// Vai trò trong game Ma Sói
enum GameRole {
  // ─── Phe Sói ───
  werewolf,
  alphaWolf,
  cursedWolf,
  wolfSorcerer,

  // ─── Phe Dân Làng ───
  villager,
  seer,
  guard,
  witch,
  hunter,
  elder,
  cupid,
  doctor,
  littleGirl,

  // ─── Đổi Phe ───
  cursedOne,
  maid,

  // ─── Phe Thứ 3 ───
  genie,
  fox,
}

extension GameRoleExtension on GameRole {
  String get displayName {
    switch (this) {
      case GameRole.werewolf:
        return 'Sói Thường';
      case GameRole.alphaWolf:
        return 'Sói Trưởng';
      case GameRole.cursedWolf:
        return 'Sói Nguyền';
      case GameRole.wolfSorcerer:
        return 'Pháp Sư Sói';
      case GameRole.villager:
        return 'Dân Làng';
      case GameRole.seer:
        return 'Tiên Tri';
      case GameRole.guard:
        return 'Bảo Vệ';
      case GameRole.witch:
        return 'Phù Thủy';
      case GameRole.hunter:
        return 'Thợ Săn';
      case GameRole.elder:
        return 'Già Làng';
      case GameRole.cupid:
        return 'Cupid';
      case GameRole.doctor:
        return 'Bác Sĩ';
      case GameRole.littleGirl:
        return 'Thiếu Niên Sói';
      case GameRole.cursedOne:
        return 'Kẻ Bị Nguyền Rủa';
      case GameRole.maid:
        return 'Người Hầu Gái';
      case GameRole.genie:
        return 'Thần Đèn';
      case GameRole.fox:
        return 'Cáo';
    }
  }

  String get description {
    switch (this) {
      case GameRole.werewolf:
        return 'Mỗi đêm thức dậy cùng bầy sói, chọn 1 người để cắn. Là sói cơ bản trong bầy.';
      case GameRole.alphaWolf:
        return 'Sói đầu đàn, có quyền quyết định cuối cùng khi bầy sói không đồng ý. Nếu chết, bầy sói mất đi thủ lĩnh.';
      case GameRole.cursedWolf:
        return 'Mỗi đêm có thể nguyền rủa 1 người, nếu người đó bị treo cổ thì sẽ biến thành sói.';
      case GameRole.wolfSorcerer:
        return 'Là sói nhưng có khả năng soi phe của 1 người mỗi đêm, tham gia cùng bầy sói khi cắn.';
      case GameRole.villager:
        return 'Dân thường, không có năng lực đặc biệt. Sử dụng lá phiếu để bảo vệ ngôi làng.';
      case GameRole.seer:
        return 'Mỗi đêm soi 1 người để biết phe. Là vai trò then chốt của phe dân làng.';
      case GameRole.guard:
        return 'Mỗi đêm bảo vệ 1 người khỏi bị sói cắn. Không được bảo vệ cùng 1 người 2 đêm liên tiếp.';
      case GameRole.witch:
        return 'Có 1 bình cứu và 1 bình độc dùng trong cả trò chơi. Có thể cứu người bị sói cắn hoặc giết 1 người.';
      case GameRole.hunter:
        return 'Khi bị chết (bởi sói hoặc bị treo cổ), được bắn chết 1 người khác trước khi chết.';
      case GameRole.elder:
        return 'Chịu được 2 lần tấn công từ sói. Nếu bị dân làng treo cổ, tất cả dân mất năng lực đặc biệt.';
      case GameRole.cupid:
        return 'Đêm đầu tiên ghép đôi 2 người. Nếu 1 trong 2 chết, người còn lại cũng chết theo.';
      case GameRole.doctor:
        return 'Mỗi đêm có thể chữa trị cho 1 người, giúp họ sống sót nếu bị tấn công.';
      case GameRole.littleGirl:
        return 'Có thể lén nhìn khi sói thức dậy để biết ai là sói, nhưng nếu bị phát hiện sẽ bị sói giết ngay.';
      case GameRole.cursedOne:
        return 'Ban đầu thuộc phe dân. Nếu bị sói cắn, không chết mà chuyển sang phe sói.';
      case GameRole.maid:
        return 'Nếu người bị treo cổ là phe dân, Người Hầu Gái có thể chết thay. Nếu là sói thì không.';
      case GameRole.genie:
        return 'Không thuộc phe nào, thắng khi sống sót đến cuối game. Mỗi đêm chọn 1 người để "bảo vệ" (giữ an toàn cho mình).';
      case GameRole.fox:
        return 'Mỗi đêm chọn 1 người, nếu trong 3 người (trái-phải-giữa) có sói thì giữ năng lực, nếu không thì mất.';
    }
  }

  String get emoji {
    switch (this) {
      case GameRole.werewolf:
        return '🐺';
      case GameRole.alphaWolf:
        return '👑';
      case GameRole.cursedWolf:
        return '💀';
      case GameRole.wolfSorcerer:
        return '🧿';
      case GameRole.villager:
        return '👤';
      case GameRole.seer:
        return '🔮';
      case GameRole.guard:
        return '🛡️';
      case GameRole.witch:
        return '🧙‍♀️';
      case GameRole.hunter:
        return '🏹';
      case GameRole.elder:
        return '👴';
      case GameRole.cupid:
        return '💘';
      case GameRole.doctor:
        return '⚕️';
      case GameRole.littleGirl:
        return '👧';
      case GameRole.cursedOne:
        return '🌑';
      case GameRole.maid:
        return '🎭';
      case GameRole.genie:
        return '🧞';
      case GameRole.fox:
        return '🦊';
    }
  }

  /// Đường dẫn hình ảnh lá bài (tương ứng field HinhAnh từ API)
  String get imagePath {
    switch (this) {
      case GameRole.werewolf:
        return '/images/la-bai-ma-soi/phe-soi/soi-thuong.png';
      case GameRole.alphaWolf:
        return '/images/la-bai-ma-soi/phe-soi/soi-truong.png';
      case GameRole.cursedWolf:
        return '/images/la-bai-ma-soi/phe-soi/soi-nguyen.png';
      case GameRole.wolfSorcerer:
        return '/images/la-bai-ma-soi/phe-soi/phap-su-soi.png';
      case GameRole.villager:
        return '/images/la-bai-ma-soi/phe-dan-lang/dan-lang.png';
      case GameRole.seer:
        return '/images/la-bai-ma-soi/phe-dan-lang/tien-tri.png';
      case GameRole.guard:
        return '/images/la-bai-ma-soi/phe-dan-lang/bao-ve.png';
      case GameRole.witch:
        return '/images/la-bai-ma-soi/phe-dan-lang/phu-thuy.png';
      case GameRole.hunter:
        return '/images/la-bai-ma-soi/phe-dan-lang/tho-san.png';
      case GameRole.elder:
        return '/images/la-bai-ma-soi/phe-dan-lang/gia-lang.png';
      case GameRole.cupid:
        return '/images/la-bai-ma-soi/phe-dan-lang/cupid.png';
      case GameRole.doctor:
        return '/images/la-bai-ma-soi/phe-dan-lang/bac-si.png';
      case GameRole.littleGirl:
        return '/images/la-bai-ma-soi/phe-dan-lang/thieu-nien-soi.png';
      case GameRole.cursedOne:
        return '/images/la-bai-ma-soi/doi-phe/ke-bi-nguyen-rua.png';
      case GameRole.maid:
        return '/images/la-bai-ma-soi/doi-phe/nguoi-hau-gai.png';
      case GameRole.genie:
        return '/images/la-bai-ma-soi/phe-thu-3/than-den.png';
      case GameRole.fox:
        return '/images/la-bai-ma-soi/phe-thu-3/cao.png';
    }
  }

  IconData get icon {
    switch (this) {
      case GameRole.werewolf:
        return Icons.pets;
      case GameRole.alphaWolf:
        return Icons.shield;
      case GameRole.cursedWolf:
        return Icons.whatshot;
      case GameRole.wolfSorcerer:
        return Icons.auto_fix_high;
      case GameRole.villager:
        return Icons.person;
      case GameRole.seer:
        return Icons.visibility;
      case GameRole.guard:
        return Icons.security;
      case GameRole.witch:
        return Icons.science;
      case GameRole.hunter:
        return Icons.gps_fixed;
      case GameRole.elder:
        return Icons.elderly;
      case GameRole.cupid:
        return Icons.favorite;
      case GameRole.doctor:
        return Icons.local_hospital;
      case GameRole.littleGirl:
        return Icons.child_care;
      case GameRole.cursedOne:
        return Icons.dark_mode;
      case GameRole.maid:
        return Icons.people_alt;
      case GameRole.genie:
        return Icons.flashlight_on;
      case GameRole.fox:
        return Icons.pest_control;
    }
  }

  Color get color {
    switch (this) {
      case GameRole.werewolf:
        return AppColors.wolfColor;
      case GameRole.alphaWolf:
        return const Color(0xFFDC2626);
      case GameRole.cursedWolf:
        return const Color(0xFFF87171);
      case GameRole.wolfSorcerer:
        return const Color(0xFFE11D48);
      case GameRole.villager:
        return AppColors.villagerColor;
      case GameRole.seer:
        return AppColors.seerColor;
      case GameRole.guard:
        return AppColors.guardColor;
      case GameRole.witch:
        return AppColors.witchColor;
      case GameRole.hunter:
        return AppColors.hunterColor;
      case GameRole.elder:
        return const Color(0xFF78716C);
      case GameRole.cupid:
        return const Color(0xFFF472B6);
      case GameRole.doctor:
        return const Color(0xFF22D3EE);
      case GameRole.littleGirl:
        return const Color(0xFFFBBF24);
      case GameRole.cursedOne:
        return const Color(0xFFFB923C);
      case GameRole.maid:
        return const Color(0xFFE5A813);
      case GameRole.genie:
        return const Color(0xFFA855F7);
      case GameRole.fox:
        return const Color(0xFFC084FC);
    }
  }

  GameTeam get team {
    switch (this) {
      case GameRole.werewolf:
      case GameRole.alphaWolf:
      case GameRole.cursedWolf:
      case GameRole.wolfSorcerer:
        return GameTeam.wolf;
      case GameRole.cursedOne:
      case GameRole.maid:
        return GameTeam.switchSide;
      case GameRole.genie:
      case GameRole.fox:
        return GameTeam.thirdParty;
      default:
        return GameTeam.villager;
    }
  }

  bool get hasNightAction {
    switch (this) {
      case GameRole.werewolf:
      case GameRole.alphaWolf:
      case GameRole.cursedWolf:
      case GameRole.wolfSorcerer:
      case GameRole.seer:
      case GameRole.guard:
      case GameRole.witch:
      case GameRole.cupid:
      case GameRole.doctor:
      case GameRole.littleGirl:
      case GameRole.fox:
      case GameRole.genie:
        return true;
      default:
        return false;
    }
  }

  int get nightOrder {
    switch (this) {
      case GameRole.cupid:
        return 0;
      case GameRole.wolfSorcerer:
        return 1;
      case GameRole.werewolf:
      case GameRole.alphaWolf:
      case GameRole.cursedWolf:
        return 2;
      case GameRole.guard:
        return 3;
      case GameRole.seer:
        return 4;
      case GameRole.witch:
        return 5;
      case GameRole.fox:
        return 6;
      case GameRole.doctor:
        return 7;
      case GameRole.genie:
        return 8;
      default:
        return 99;
    }
  }

  String get khaNangDem {
    switch (this) {
      case GameRole.werewolf:
        return 'Cùng bầy sói chọn 1 người để cắn mỗi đêm.';
      case GameRole.alphaWolf:
        return 'Quyết định cuối cùng khi bầy sói bất đồng. Cùng bầy sói cắn 1 người.';
      case GameRole.cursedWolf:
        return 'Nguyền rủa 1 người mỗi đêm. Cùng bầy sói cắn 1 người.';
      case GameRole.wolfSorcerer:
        return 'Soi phe 1 người trước khi bầy sói hành động. Cùng bầy sói cắn 1 người.';
      case GameRole.villager:
        return 'Không có khả năng đặc biệt.';
      case GameRole.seer:
        return 'Soi 1 người để biết phe (Dân hoặc Sói).';
      case GameRole.guard:
        return 'Bảo vệ 1 người khỏi bị sói cắn. Không được bảo vệ cùng 1 người 2 đêm liên tiếp.';
      case GameRole.witch:
        return 'Cứu người bị sói cắn (thuốc cứu) hoặc giết 1 người (thuốc độc). Có thể dùng cả 2 trong 1 đêm.';
      case GameRole.hunter:
        return 'Không có khả năng đặc biệt ban đêm.';
      case GameRole.elder:
        return 'Không có khả năng đặc biệt ban đêm.';
      case GameRole.cupid:
        return 'Đêm đầu tiên: ghép đôi 2 người yêu nhau.';
      case GameRole.doctor:
        return 'Chữa trị 1 người mỗi đêm, giúp họ sống sót nếu bị tấn công.';
      case GameRole.littleGirl:
        return 'Lén nhìn khi sói thức dậy để biết ai là sói (rủi ro bị phát hiện).';
      case GameRole.cursedOne:
        return 'Được quản trò xác nhận trạng thái (đã bị cắn chuyển phe hay chưa).';
      case GameRole.maid:
        return 'Không có khả năng đặc biệt ban đêm.';
      case GameRole.genie:
        return 'Chọn 1 người để "bảo vệ", giữ an toàn cho mình qua đêm.';
      case GameRole.fox:
        return 'Chọn 1 người, kiểm tra 3 người liền kề (trái-giữa-phải) có sói hay không.';
    }
  }

  String get khaNangNgay {
    switch (this) {
      case GameRole.werewolf:
      case GameRole.alphaWolf:
      case GameRole.cursedWolf:
      case GameRole.wolfSorcerer:
        return 'Giả dạng dân làng, thảo luận và bỏ phiếu.';
      case GameRole.villager:
        return 'Thảo luận và bỏ phiếu treo cổ.';
      case GameRole.seer:
        return 'Không có khả năng đặc biệt.';
      case GameRole.guard:
        return 'Không có khả năng đặc biệt.';
      case GameRole.witch:
        return 'Không có khả năng đặc biệt.';
      case GameRole.hunter:
        return 'Khi bị chết (sói cắn hoặc treo cổ), bắn chết 1 người trước khi chết.';
      case GameRole.elder:
        return 'Nếu bị dân làng treo cổ, tất cả dân mất năng lực đặc biệt.';
      case GameRole.cupid:
        return 'Không có khả năng đặc biệt.';
      case GameRole.doctor:
        return 'Không có khả năng đặc biệt.';
      case GameRole.littleGirl:
        return 'Không có khả năng đặc biệt.';
      case GameRole.cursedOne:
        return 'Không có khả năng đặc biệt.';
      case GameRole.maid:
        return 'Nếu người bị treo cổ là phe dân, có thể chết thay.';
      case GameRole.genie:
        return 'Không có khả năng đặc biệt.';
      case GameRole.fox:
        return 'Không có khả năng đặc biệt.';
    }
  }

  String? get ghiChu {
    switch (this) {
      case GameRole.werewolf:
        return null;
      case GameRole.alphaWolf:
        return 'Nếu Sói Trưởng chết, bầy sói mất đi thủ lĩnh.';
      case GameRole.cursedWolf:
        return 'Người bị nguyền nếu bị treo cổ sẽ biến thành sói.';
      case GameRole.wolfSorcerer:
        return 'Soi phe diễn ra TRƯỚC khi bầy sói cắn.';
      case GameRole.villager:
        return null;
      case GameRole.seer:
        return 'Vai trò then chốt của phe dân làng.';
      case GameRole.guard:
        return 'Không thể bảo vệ cùng 1 người 2 đêm liên tiếp.';
      case GameRole.witch:
        return 'Mỗi bình thuốc chỉ dùng được 1 lần trong cả trò chơi.';
      case GameRole.hunter:
        return 'Nếu bị Phù Thủy đầu độc, không được bắn.';
      case GameRole.elder:
        return 'Chịu được 2 lần tấn công từ sói trước khi chết.';
      case GameRole.cupid:
        return 'Chỉ ghép đôi vào đêm đầu tiên.';
      case GameRole.doctor:
        return null;
      case GameRole.littleGirl:
        return 'Nếu bị sói phát hiện lén nhìn, sẽ bị giết ngay.';
      case GameRole.cursedOne:
        return 'Sau khi chuyển phe, sẽ thức dậy cùng bầy sói mỗi đêm.';
      case GameRole.maid:
        return 'Chỉ chết thay nếu người bị treo cổ là phe dân.';
      case GameRole.genie:
        return 'Thắng khi sống sót đến cuối game.';
      case GameRole.fox:
        return 'Nếu không phát hiện sói, mất năng lực vĩnh viễn.';
    }
  }

  /// Lấy danh sách vai trò theo phe
  static List<GameRole> byTeam(GameTeam team) {
    return GameRole.values.where((r) => r.team == team).toList();
  }
}
