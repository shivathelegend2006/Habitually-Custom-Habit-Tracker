class Habit {
  final int? id;
  final String name;
  final String colorCode;
  final bool isArchived;
  final bool isPaused;
  final DateTime createdAt;
  final int maxStreak;
  final int activeDays;

  const Habit({
    this.id,
    required this.name,
    required this.colorCode,
    this.isArchived = false,
    this.isPaused = false,
    required this.createdAt,
    this.maxStreak = 0,
    this.activeDays = 0,
  });

  /// Creates a copy of this habit with specified attributes updated.
  Habit copyWith({
    int? id,
    String? name,
    String? colorCode,
    bool? isArchived,
    bool? isPaused,
    DateTime? createdAt,
    int? maxStreak,
    int? activeDays,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
      isArchived: isArchived ?? this.isArchived,
      isPaused: isPaused ?? this.isPaused,
      createdAt: createdAt ?? this.createdAt,
      maxStreak: maxStreak ?? this.maxStreak,
      activeDays: activeDays ?? this.activeDays,
    );
  }

  /// Converts the Habit instance to an SQLite-compatible Map.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'color_code': colorCode,
      'is_archived': isArchived ? 1 : 0,
      'is_paused': isPaused ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'max_streak': maxStreak,
      'active_days': activeDays,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Constructs a Habit instance from an SQLite record Map.
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorCode: map['color_code'] as String,
      isArchived: (map['is_archived'] as int?) == 1,
      isPaused: (map['is_paused'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      maxStreak: (map['max_streak'] as int?) ?? 0,
      activeDays: (map['active_days'] as int?) ?? 0,
    );
  }
}
