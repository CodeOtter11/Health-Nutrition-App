class Reminder {
  String id;
  String title;
  int time;
  bool enabled;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    this.enabled = true,
  });

  // Convert object → Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'enabled': enabled,
    };
  }

  // Convert Map → object
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      time: json['time'] as int,
      enabled: json['enabled'] as bool,
    );
  }
}