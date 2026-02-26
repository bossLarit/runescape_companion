import 'package:uuid/uuid.dart';

enum CharacterType {
  main,
  iron,
  hcim,
  uim,
  gim,
  alt,
  pure,
  skiller,
  custom;

  String get displayName {
    switch (this) {
      case CharacterType.main:
        return 'Main';
      case CharacterType.iron:
        return 'Ironman';
      case CharacterType.hcim:
        return 'HCIM';
      case CharacterType.uim:
        return 'UIM';
      case CharacterType.gim:
        return 'GIM';
      case CharacterType.alt:
        return 'Alt';
      case CharacterType.pure:
        return 'Pure';
      case CharacterType.skiller:
        return 'Skiller';
      case CharacterType.custom:
        return 'Custom';
    }
  }
}

class Character {
  final String id;
  final String displayName;
  final CharacterType characterType;
  final String loginLabel;
  final int avatarColorValue;
  final String notes;
  final List<String> tags;
  final bool isActive;
  final String currentGrind;
  final String nextLoginPurpose;
  final SecurityChecklist securityChecklist;
  final DateTime createdAt;
  final DateTime updatedAt;

  Character({
    String? id,
    required this.displayName,
    this.characterType = CharacterType.main,
    this.loginLabel = '',
    this.avatarColorValue = 0xFF1B5E20,
    this.notes = '',
    this.tags = const [],
    this.isActive = true,
    this.currentGrind = '',
    this.nextLoginPurpose = '',
    SecurityChecklist? securityChecklist,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        securityChecklist = securityChecklist ?? SecurityChecklist(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Character copyWith({
    String? displayName,
    CharacterType? characterType,
    String? loginLabel,
    int? avatarColorValue,
    String? notes,
    List<String>? tags,
    bool? isActive,
    String? currentGrind,
    String? nextLoginPurpose,
    SecurityChecklist? securityChecklist,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id,
      displayName: displayName ?? this.displayName,
      characterType: characterType ?? this.characterType,
      loginLabel: loginLabel ?? this.loginLabel,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      currentGrind: currentGrind ?? this.currentGrind,
      nextLoginPurpose: nextLoginPurpose ?? this.nextLoginPurpose,
      securityChecklist: securityChecklist ?? this.securityChecklist,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'characterType': characterType.name,
        'loginLabel': loginLabel,
        'avatarColorValue': avatarColorValue,
        'notes': notes,
        'tags': tags,
        'isActive': isActive,
        'currentGrind': currentGrind,
        'nextLoginPurpose': nextLoginPurpose,
        'securityChecklist': securityChecklist.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? 'Unknown',
      characterType: CharacterType.values.firstWhere(
        (e) => e.name == json['characterType'],
        orElse: () => CharacterType.main,
      ),
      loginLabel: json['loginLabel'] as String? ?? '',
      avatarColorValue: json['avatarColorValue'] as int? ?? 0xFF1B5E20,
      notes: json['notes'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['isActive'] as bool? ?? true,
      currentGrind: json['currentGrind'] as String? ?? '',
      nextLoginPurpose: json['nextLoginPurpose'] as String? ?? '',
      securityChecklist: json['securityChecklist'] != null
          ? SecurityChecklist.fromJson(json['securityChecklist'] as Map<String, dynamic>)
          : SecurityChecklist(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}

class SecurityChecklist {
  final bool jagexAccountMigrated;
  final bool twoFactorEnabled;
  final bool email2faEnabled;
  final bool bankPinEnabled;
  final bool backupCodesStored;
  final DateTime? lastSecurityReview;
  final String notes;

  SecurityChecklist({
    this.jagexAccountMigrated = false,
    this.twoFactorEnabled = false,
    this.email2faEnabled = false,
    this.bankPinEnabled = false,
    this.backupCodesStored = false,
    this.lastSecurityReview,
    this.notes = '',
  });

  SecurityChecklist copyWith({
    bool? jagexAccountMigrated,
    bool? twoFactorEnabled,
    bool? email2faEnabled,
    bool? bankPinEnabled,
    bool? backupCodesStored,
    DateTime? lastSecurityReview,
    String? notes,
  }) {
    return SecurityChecklist(
      jagexAccountMigrated: jagexAccountMigrated ?? this.jagexAccountMigrated,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      email2faEnabled: email2faEnabled ?? this.email2faEnabled,
      bankPinEnabled: bankPinEnabled ?? this.bankPinEnabled,
      backupCodesStored: backupCodesStored ?? this.backupCodesStored,
      lastSecurityReview: lastSecurityReview ?? this.lastSecurityReview,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'jagexAccountMigrated': jagexAccountMigrated,
        'twoFactorEnabled': twoFactorEnabled,
        'email2faEnabled': email2faEnabled,
        'bankPinEnabled': bankPinEnabled,
        'backupCodesStored': backupCodesStored,
        'lastSecurityReview': lastSecurityReview?.toIso8601String(),
        'notes': notes,
      };

  factory SecurityChecklist.fromJson(Map<String, dynamic> json) {
    return SecurityChecklist(
      jagexAccountMigrated: json['jagexAccountMigrated'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      email2faEnabled: json['email2faEnabled'] as bool? ?? false,
      bankPinEnabled: json['bankPinEnabled'] as bool? ?? false,
      backupCodesStored: json['backupCodesStored'] as bool? ?? false,
      lastSecurityReview: json['lastSecurityReview'] != null
          ? DateTime.parse(json['lastSecurityReview'] as String)
          : null,
      notes: json['notes'] as String? ?? '',
    );
  }

  int get completedCount {
    int count = 0;
    if (jagexAccountMigrated) count++;
    if (twoFactorEnabled) count++;
    if (email2faEnabled) count++;
    if (bankPinEnabled) count++;
    if (backupCodesStored) count++;
    return count;
  }

  int get totalCount => 5;
}
