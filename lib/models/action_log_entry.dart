class ActionLogEntry {
  ActionLogEntry({
    required this.id,
    this.userName,
    this.role,
    this.tripId,
    required this.action,
    this.oldValue,
    this.newValue,
    this.reason,
    this.urgency,
    this.createdAt,
  });

  final String id;
  final String? userName;
  final String? role;
  final String? tripId;
  final String action;
  final String? oldValue;
  final String? newValue;
  final String? reason;
  final String? urgency;
  final String? createdAt;

  factory ActionLogEntry.fromMap(Map<String, dynamic> map) {
    return ActionLogEntry(
      id: map['id'].toString(),
      userName: map['user_name']?.toString(),
      role: map['role']?.toString(),
      tripId: map['trip_id']?.toString(),
      action: map['action']?.toString() ?? '',
      oldValue: map['old_value']?.toString(),
      newValue: map['new_value']?.toString(),
      reason: map['reason']?.toString(),
      urgency: map['urgency']?.toString(),
      createdAt: map['created_at']?.toString(),
    );
  }
}
