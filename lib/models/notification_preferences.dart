class NotificationPreferences {
  final EmailPreferences email;
  final DatabasePreferences database;

  NotificationPreferences({
    required this.email,
    required this.database,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      email: EmailPreferences.fromJson(json['email']),
      database: DatabasePreferences.fromJson(json['database']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email.toJson(),
      'database': database.toJson(),
    };
  }

  NotificationPreferences copyWith({
    EmailPreferences? email,
    DatabasePreferences? database,
  }) {
    return NotificationPreferences(
      email: email ?? this.email,
      database: database ?? this.database,
    );
  }
}

class EmailPreferences {
  final bool subscriptions;
  final bool social;
  final bool events;
  final bool financial;

  EmailPreferences({
    required this.subscriptions,
    required this.social,
    required this.events,
    required this.financial,
  });

  factory EmailPreferences.fromJson(Map<String, dynamic> json) {
    return EmailPreferences(
      subscriptions: json['subscriptions'] ?? true,
      social: json['social'] ?? true,
      events: json['events'] ?? true,
      financial: json['financial'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptions': subscriptions,
      'social': social,
      'events': events,
      'financial': financial,
    };
  }

  EmailPreferences copyWith({
    bool? subscriptions,
    bool? social,
    bool? events,
    bool? financial,
  }) {
    return EmailPreferences(
      subscriptions: subscriptions ?? this.subscriptions,
      social: social ?? this.social,
      events: events ?? this.events,
      financial: financial ?? this.financial,
    );
  }
}

class DatabasePreferences {
  final bool subscriptions;
  final bool social;
  final bool events;
  final bool financial;

  DatabasePreferences({
    required this.subscriptions,
    required this.social,
    required this.events,
    required this.financial,
  });

  factory DatabasePreferences.fromJson(Map<String, dynamic> json) {
    return DatabasePreferences(
      subscriptions: json['subscriptions'] ?? true,
      social: json['social'] ?? true,
      events: json['events'] ?? true,
      financial: json['financial'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptions': subscriptions,
      'social': social,
      'events': events,
      'financial': financial,
    };
  }

  DatabasePreferences copyWith({
    bool? subscriptions,
    bool? social,
    bool? events,
    bool? financial,
  }) {
    return DatabasePreferences(
      subscriptions: subscriptions ?? this.subscriptions,
      social: social ?? this.social,
      events: events ?? this.events,
      financial: financial ?? this.financial,
    );
  }
}
