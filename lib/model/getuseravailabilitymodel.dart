// GetUserAvailabilityModel - Response model for user availability API
// Endpoint: GET /api/v1/users/{userId}/availability?date=YYYY-MM-DD

import 'dart:convert';

Getuseravailabilitymodel getuseravailabilitymodelFromJson(String str) =>
    Getuseravailabilitymodel.fromJson(json.decode(str));

String getuseravailabilitymodelToJson(Getuseravailabilitymodel data) =>
    json.encode(data.toJson());

class Getuseravailabilitymodel {
  bool success;
  bool isHoliday;
  AvailableHours availableHours;
  List<AvailableSlot> availableSlots;
  List<BookedSlot> bookedSlots;
  String dayOfWeek;
  DateTime date;

  Getuseravailabilitymodel({
    required this.success,
    required this.isHoliday,
    required this.availableHours,
    required this.availableSlots,
    required this.bookedSlots,
    required this.dayOfWeek,
    required this.date,
  });

  // Helper function to parse bool from int/bool/string
  static bool _parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return defaultValue;
  }

  factory Getuseravailabilitymodel.fromJson(Map<String, dynamic> json) {
    return Getuseravailabilitymodel(
      success: _parseBool(json['success']),
      isHoliday: _parseBool(json['is_holiday']),
      availableHours: json['available_hours'] != null
          ? AvailableHours.fromJson(json['available_hours'])
          : AvailableHours(startTime: '', endTime: ''),
      availableSlots: json['available_slots'] != null
          ? (json['available_slots'] as List)
              .map((e) => AvailableSlot.fromJson(e))
              .toList()
          : [],
      bookedSlots: json['booked_slots'] != null
          ? (json['booked_slots'] as List)
              .map((e) => BookedSlot.fromJson(e))
              .toList()
          : [],
      dayOfWeek: json['day_of_week'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'is_holiday': isHoliday,
        'available_hours': availableHours.toJson(),
        'available_slots': availableSlots.map((e) => e.toJson()).toList(),
        'booked_slots': bookedSlots.map((e) => e.toJson()).toList(),
        'day_of_week': dayOfWeek,
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      };
}

class AvailableHours {
  String startTime;
  String endTime;

  AvailableHours({
    required this.startTime,
    required this.endTime,
  });

  factory AvailableHours.fromJson(Map<String, dynamic> json) {
    return AvailableHours(
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'start_time': startTime,
        'end_time': endTime,
      };
}

class AvailableSlot {
  String start;
  String end;
  String display;

  AvailableSlot({
    required this.start,
    required this.end,
    required this.display,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      display: json['display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'display': display,
      };
}

class BookedSlot {
  String start;
  String end;
  String display;
  int? bookingId;
  String? status;

  BookedSlot({
    required this.start,
    required this.end,
    required this.display,
    this.bookingId,
    this.status,
  });

  factory BookedSlot.fromJson(Map<String, dynamic> json) {
    return BookedSlot(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      display: json['display'] ?? '',
      bookingId: json['booking_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'display': display,
        'booking_id': bookingId,
        'status': status,
      };
}
