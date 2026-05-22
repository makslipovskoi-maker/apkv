class Trip {
  Trip({
    required this.id,
    required this.tripCode,
    this.requestId,
    required this.departureDate,
    this.vehicleTime,
    this.recommendedTime,
    required this.corps,
    required this.room,
    required this.guestName,
    required this.peopleCount,
    this.baggage,
    required this.direction,
    this.destination,
    this.ticketTime,
    this.vehicle,
    this.driverName,
    this.driverPhone,
    required this.status,
    this.driverConfirmedAt,
    this.mechanicConfirmedAt,
    this.comment,
    this.problem,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  final String id;
  final String tripCode;
  final String? requestId;
  final String departureDate;
  final String? vehicleTime;
  final String? recommendedTime;
  final String corps;
  final String room;
  final String guestName;
  final int peopleCount;
  final String? baggage;
  final String direction;
  final String? destination;
  final String? ticketTime;
  final String? vehicle;
  final String? driverName;
  final String? driverPhone;
  final String status;
  final String? driverConfirmedAt;
  final String? mechanicConfirmedAt;
  final String? comment;
  final String? problem;
  final String? createdBy;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? completedAt;

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'].toString(),
      tripCode: map['trip_code']?.toString() ?? '—',
      requestId: map['request_id']?.toString(),
      departureDate: map['departure_date']?.toString() ?? '',
      vehicleTime: map['vehicle_time']?.toString(),
      recommendedTime: map['recommended_time']?.toString(),
      corps: map['corps']?.toString() ?? '',
      room: map['room']?.toString() ?? '',
      guestName: map['guest_name']?.toString() ?? '',
      peopleCount: (map['people_count'] as num?)?.toInt() ?? 1,
      baggage: map['baggage']?.toString(),
      direction: map['direction']?.toString() ?? '',
      destination: map['destination']?.toString(),
      ticketTime: map['ticket_time']?.toString(),
      vehicle: map['vehicle']?.toString(),
      driverName: map['driver_name']?.toString(),
      driverPhone: map['driver_phone']?.toString(),
      status: map['status']?.toString() ?? 'В расписании',
      driverConfirmedAt: map['driver_confirmed_at']?.toString(),
      mechanicConfirmedAt: map['mechanic_confirmed_at']?.toString(),
      comment: map['comment']?.toString(),
      problem: map['problem']?.toString(),
      createdBy: map['created_by']?.toString(),
      updatedBy: map['updated_by']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      completedAt: map['completed_at']?.toString(),
    );
  }

  bool get hasProblem => status == 'Проблема' || (problem != null && problem!.trim().isNotEmpty);
  bool get needsAttention {
    return vehicle == null ||
        vehicle!.isEmpty ||
        driverName == null ||
        driverName!.isEmpty ||
        driverConfirmedAt == null ||
        status == 'Срочное изменение' ||
        status == 'Проблема' ||
        hasProblem;
  }
}
