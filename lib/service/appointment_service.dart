import 'package:dio/dio.dart';
import '../helper/global_variables.dart';
import '../bloc/auth/authentication_bloc.dart';
import '../model/appointment.dart';

class AppointmentService {
  final Dio _dio = Dio();
  final String _baseUrl = GlobalVariables().apiString;

  /// Book a new appointment with a doctor
  Future<bool> bookAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    String? notes,
  }) async {
    try {
      final auth = await AuthenticationBloc.readAuth();
      final token = auth?['token'];

      if (token == null) {
        throw Exception('User not authenticated');
      }

      try {
        final response = await _dio.post(
          '$_baseUrl/appointments',
          data: {
            'doctorId': doctorId,
            'appointmentDate': appointmentDate.toIso8601String(),
            'notes': notes,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => true, // Accept any status code to handle it manually
          ),
        );

        if (response.statusCode == 201) {
          print('Successfully booked appointment with doctor $doctorId at ${appointmentDate.toString()}');
          return true;
        } else {
          print('API Error: Status ${response.statusCode}, Response: ${response.data}');
          // Show more specific error message based on status code
          if (response.statusCode == 400) {
            print('Invalid appointment data or time slot not available');
          } else if (response.statusCode == 404) {
            print('Doctor not found');
          }
          return false;
        }
      } on DioException catch (dioError) {
        print('Dio Error: ${dioError.message}, ${dioError.response?.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error booking appointment: $e');
      return false;
    }
  }

  /// Get all appointments for the current user
  Future<List<Appointment>> getUserAppointments() async {
    try {
      final auth = await AuthenticationBloc.readAuth();
      final token = auth?['token'];

      if (token == null) {
        throw Exception('User not authenticated');
      }

      try {
        final response = await _dio.get(
        '$_baseUrl/appointments/my-appointments',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => true, // Accept any status code to handle it manually
        ),
      );

        if (response.statusCode == 200) {
          final List<dynamic> appointmentsData = response.data;
          return appointmentsData.map((data) => Appointment.fromJson(data)).toList();
        } else {
          print('API Error: Status ${response.statusCode}, Response: ${response.data}');
          throw Exception('Failed to fetch appointments: Status ${response.statusCode}');
        }
      } on DioException catch (dioError) {
        print('Dio Error: ${dioError.message}, ${dioError.response?.statusCode}');
        if (dioError.response?.statusCode == 404) {
          // If endpoint not found, return empty list instead of throwing
          print('Appointments endpoint not found, returning empty list');
          return [];
        }
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      print('Error in getUserAppointments: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  /// Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final auth = await AuthenticationBloc.readAuth();
      final token = auth?['token'];

      if (token == null) {
        throw Exception('User not authenticated');
      }

      try {
        final response = await _dio.post(
          '$_baseUrl/appointments/$appointmentId/cancel',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => true, // Accept any status code to handle it manually
          ),
        );

        if (response.statusCode == 200) {
          print('Successfully cancelled appointment $appointmentId');
          return true;
        } else {
          print('API Error: Status ${response.statusCode}, Response: ${response.data}');
          // Show more specific error message based on status code
          if (response.statusCode == 403) {
            print('Cannot cancel appointment: Permission denied or already completed');
          } else if (response.statusCode == 404) {
            print('Appointment not found');
          }
          return false;
        }
      } on DioException catch (dioError) {
        print('Dio Error: ${dioError.message}, ${dioError.response?.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      return false;
    }
  }

  /// Check if user has an active appointment with a doctor
  Future<bool> hasActiveAppointmentWithDoctor(String doctorId) async {
    try {
      final appointments = await getUserAppointments();
      if (appointments.isEmpty) {
        print('No appointments found for this user');
        return false;
      }
      
      final now = DateTime.now();
      
      // Check if there's any confirmed appointment with this doctor that is current or in the future
      final hasActive = appointments.any((appointment) {
        try {
          final appointmentDate = appointment.appointmentDate;
          final status = appointment.status;
          final appointmentDoctorId = appointment.doctorId is String 
              ? appointment.doctorId 
              : (appointment.doctorId is Map ? appointment.doctorId['_id'] : null);
          
          if (appointmentDoctorId == null) {
            print('Warning: Could not determine doctor ID from appointment');
            return false;
          }
          
          final isActive = appointmentDoctorId == doctorId && 
                 status == 'confirmed' && 
                 appointmentDate.isAfter(now);
                 
          if (isActive) {
            print('Found active appointment with doctor $doctorId at ${appointmentDate.toString()}');
          }
          
          return isActive;
        } catch (e) {
          print('Error processing appointment: $e');
          return false;
        }
      });
      
      return hasActive;
    } catch (e) {
      print('Error in hasActiveAppointmentWithDoctor: $e');
      return false;
    }
  }
  
  /// Update appointment status (for doctors/admin)
  Future<bool> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final auth = await AuthenticationBloc.readAuth();
      final token = auth?['token'];

      if (token == null) {
        throw Exception('User not authenticated');
      }
      
      // Validate status
      if (!['pending', 'confirmed', 'cancelled', 'completed'].contains(status)) {
        throw Exception('Invalid status value');
      }

      final response = await _dio.patch(
        '$_baseUrl/appointments/$appointmentId/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error updating appointment status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }
  
  /// Get doctor's appointments (for doctors)
  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    try {
      final auth = await AuthenticationBloc.readAuth();
      final token = auth?['token'];

      if (token == null) {
        throw Exception('User not authenticated');
      }

      try {
        final response = await _dio.get(
          '$_baseUrl/appointments/doctor/$doctorId',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => true, // Accept any status code to handle it manually
          ),
        );

        if (response.statusCode == 200) {
          final List<dynamic> appointmentsData = response.data;
          return appointmentsData.map((data) => Appointment.fromJson(data)).toList();
        } else {
          print('API Error: Status ${response.statusCode}, Response: ${response.data}');
          throw Exception('Failed to fetch doctor appointments: Status ${response.statusCode}');
        }
      } on DioException catch (dioError) {
        print('Dio Error: ${dioError.message}, ${dioError.response?.statusCode}');
        if (dioError.response?.statusCode == 404) {
          // If endpoint not found, return empty list instead of throwing
          print('Doctor appointments endpoint not found, returning empty list');
          return [];
        }
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      print('Error in getDoctorAppointments: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }
  
  /// Get a specific appointment by ID
  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      final auth = await AuthenticationBloc.readAuth();
      final token = auth?['token'];

      if (token == null) {
        throw Exception('User not authenticated');
      }

      try {
        final response = await _dio.get(
          '$_baseUrl/appointments/$appointmentId',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => true, // Accept any status code to handle it manually
          ),
        );

        if (response.statusCode == 200) {
          return Appointment.fromJson(response.data);
        } else {
          print('API Error: Status ${response.statusCode}, Response: ${response.data}');
          if (response.statusCode == 404) {
            print('Appointment not found');
            return null;
          }
          throw Exception('Failed to fetch appointment: Status ${response.statusCode}');
        }
      } on DioException catch (dioError) {
        print('Dio Error: ${dioError.message}, ${dioError.response?.statusCode}');
        if (dioError.response?.statusCode == 404) {
          print('Appointment not found');
          return null;
        }
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      print('Error in getAppointmentById: $e');
      return null;
    }
  }
}