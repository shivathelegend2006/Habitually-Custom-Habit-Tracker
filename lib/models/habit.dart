class Habit {
  final int? id;
  final String name;
  final String colorCode;
  final bool isArchived;
  final DateTime createdAt;

  const Habit({
    this.id,
    required this.name,
    required this.colorCode,
    this.isArchived = false,
    required this.createdAt,
  });

  /// Creates a copy of this habit with specified attributes updated.
  Habit copyWith({
    int? id,
    String? name,
    String? colorCode,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      colorCode: colorCode ?? this.colorCode,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts the Habit instance to an SQLite-compatible Map.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'color_code': colorCode,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
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
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
