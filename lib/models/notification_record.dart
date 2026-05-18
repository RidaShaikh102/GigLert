class NotificationRecord {
  const NotificationRecord({
    required this.id,
    required this.packageName,
    required this.title,
    required this.body,
    required this.type,
    required this.receivedAt,
    required this.alarmTriggered,
  });

  final String id;
  final String packageName;
  final String title;
  final String body;
  final String type;
  final DateTime receivedAt;
  final bool alarmTriggered;

  factory NotificationRecord.fromJson(Map<String, dynamic> json) {
    return NotificationRecord(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      packageName: json['packageName'] as String? ?? '',
      title: json['title'] as String? ?? 'Fiverr notification',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      receivedAt: DateTime.fromMillisecondsSinceEpoch(
        json['receivedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      alarmTriggered: json['alarmTriggered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'packageName': packageName,
      'title': title,
      'body': body,
      'type': type,
      'receivedAt': receivedAt.millisecondsSinceEpoch,
      'alarmTriggered': alarmTriggered,
    };
  }

  String get displayTitle => title.trim().isEmpty ? 'Fiverr alert' : title;

  String get displayBody =>
      body.trim().isEmpty ? 'New Fiverr activity detected.' : body;

  static String inferType(String title, String body) {
    final String haystack = '$title $body'.toLowerCase();
    if (haystack.contains('order')) {
      return 'order';
    }
    if (haystack.contains('reply') || haystack.contains('response')) {
      return 'reply';
    }
    if (haystack.contains('message') ||
        haystack.contains('buyer') ||
        haystack.contains('inbox')) {
      return 'message';
    }
    return 'general';
  }
}
