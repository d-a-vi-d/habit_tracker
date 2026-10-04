class Entry {
  final DateTime date;
  final Map<String, dynamic> triggers;
  final Map<String, dynamic> symptoms;

  Entry({
    required this.date,
    required this.triggers,
    required this.symptoms,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'triggers': triggers,
      'symptoms': symptoms,
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      date: DateTime.parse(json['date']),
      triggers: Map<String, dynamic>.from(json['triggers']),
      symptoms: Map<String, dynamic>.from(json['symptoms']),
    );
  }
}
