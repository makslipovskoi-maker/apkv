class GuestRequest {
  GuestRequest({
    required this.id,
    required this.corps,
    required this.room,
    required this.guestName,
    required this.peopleCount,
    this.baggage,
    required this.departureDate,
    required this.direction,
    this.destination,
    this.ticketTime,
    required this.transferNeeded,
    this.comment,
    required this.status,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String corps;
  final String room;
  final String guestName;
  final int peopleCount;
  final String? baggage;
  final String departureDate;
  final String direction;
  final String? destination;
  final String? ticketTime;
  final bool transferNeeded;
  final String? comment;
  final String status;
  final String? createdBy;
  final String? createdAt;

  factory GuestRequest.fromMap(Map<String, dynamic> map) {
    return GuestRequest(
      id: map['id'].toString(),
      corps: map['corps']?.toString() ?? '',
      room: map['room']?.toString() ?? '',
      guestName: map['guest_name']?.toString() ?? '',
      peopleCount: (map['people_count'] as num?)?.toInt() ?? 1,
      baggage: map['baggage']?.toString(),
      departureDate: map['departure_date']?.toString() ?? '',
      direction: map['direction']?.toString() ?? '',
      destination: map['destination']?.toString(),
      ticketTime: map['ticket_time']?.toString(),
      transferNeeded: map['transfer_needed'] != false,
      comment: map['comment']?.toString(),
      status: map['status']?.toString() ?? 'Новая заявка',
      createdBy: map['created_by']?.toString(),
      createdAt: map['created_at']?.toString(),
    );
  }
}
