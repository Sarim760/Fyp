import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final dynamic doctorId; // Can be String or Doctor object
  final dynamic userId; // Can be String or User object
  final DateTime appointmentDate;
  final String status;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.appointmentDate,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['_id'] ?? json['id'],
        doctorId: json['doctorId'],
        userId: json['userId'],
        appointmentDate: DateTime.parse(json['appointmentDate']),
        status: json['status'],
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorId': doctorId is String ? doctorId : doctorId['_id'],
        'userId': userId is String ? userId : userId['_id'],
        'appointmentDate': appointmentDate.toIso8601String(),
        'status': status,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  bool isActive() {
    final now = DateTime.now();
    // An appointment is active if it's confirmed and either:
    // 1. It's in the future (upcoming)
    // 2. It's currently happening (within a reasonable window, e.g., 1 hour)
    if (status != 'confirmed') return false;
    
    // If appointment is in the future
    if (appointmentDate.isAfter(now)) return true;
    
    // If appointment is currently happening (within 1 hour after start time)
    final appointmentEndTime = appointmentDate.add(const Duration(hours: 1));
    return now.isBefore(appointmentEndTime);
  }

  bool isPending() {
    return status == 'pending';
  }

  bool isCancelled() {
    return status == 'cancelled';
  }

  bool isCompleted() {
    return status == 'completed';
  }

  String getStatusText() {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}