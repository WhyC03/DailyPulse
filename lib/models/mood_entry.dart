class MoodEntry {
  final String id;
  final String emoji;
  final String note;
  final DateTime date;
  final String userId;

  MoodEntry({
    required this.id,
    required this.emoji,
    required this.note,
    required this.date,
    required this.userId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emoji': emoji,
      'note': note,
      'date': date.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Create from Map (from Firestore)
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] ?? '',
      emoji: map['emoji'] ?? '',
      note: map['note'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      userId: map['userId'] ?? '',
    );
  }

  // Convert to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emoji': emoji,
      'note': note,
      'date': date.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Create from JSON (from SharedPreferences)
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] ?? '',
      emoji: json['emoji'] ?? '',
      note: json['note'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? 0),
      userId: json['userId'] ?? '',
    );
  }

  // Copy with method for updates
  MoodEntry copyWith({
    String? id,
    String? emoji,
    String? note,
    DateTime? date,
    String? userId,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }

  // Helper method to determine if mood is positive
  bool get isPositive {
    const positiveEmojis = ['😊', '😄', '😁', '🤗', '🥰', '😍', '🤩', '😇'];
    return positiveEmojis.contains(emoji);
  }

  // Helper method to determine if mood is negative
  bool get isNegative {
    const negativeEmojis = ['😢', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖', '😫', '😩'];
    return negativeEmojis.contains(emoji);
  }

  // Helper method to determine if mood is neutral
  bool get isNeutral {
    const neutralEmojis = ['😐', '😑', '😶', '🙄', '😏', '🤔', '😌'];
    return neutralEmojis.contains(emoji);
  }
}
