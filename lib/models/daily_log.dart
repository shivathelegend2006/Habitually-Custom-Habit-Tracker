class DailyLog {
  final int? id;
  final int habitId;
  final String logDate; // Format: YYYY-MM-DD
  final int intensity; // Value between 1 and 10
  final String? note;

  DailyLog({
    this.id,
    required this.habitId,
    required this.logDate,
    required this.intensity,
    this.note,
  }) : assert(
          intensity >= 1 && intensity <= 10,
          'Intensity must be an integer between 1 and 10.',
        );

  /// Creates a copy of this daily log with specified attributes updated.
  DailyLog copyWith({
    int? id,
    int? habitId,
    String? logDate,
    int? intensity,
    String? note,
  }) {
    return DailyLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      logDate: logDate ?? this.logDate,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
    );
  }

  /// Converts the DailyLog instance to an SQLite-compatible Map.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'habit_id': habitId,
      'log_date': logDate,
      'intensity': intensity,
      'note': note,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Constructs a DailyLog instance from an SQLite record Map.
  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      logDate: map['log_date'] as String,
      intensity: map['intensity'] as int,
      note: map['note'] as String?,
    );
  }
}
