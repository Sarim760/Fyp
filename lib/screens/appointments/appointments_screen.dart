import 'package:flutter/material.dart';
import '../../model/appointment.dart';
import '../../service/appointment_service.dart';
import '../../screens/chat/doctor_chat_screen.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointments = await _appointmentService.getUserAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Appointment> _getFilteredAppointments(String status) {
    if (status == 'all') {
      return _appointments;
    }
    return _appointments.where((appointment) => appointment.status == status).toList();
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      final success = await _appointmentService.cancelAppointment(appointmentId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _appointments.isEmpty
                  ? const Center(child: Text('No appointments found'))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAppointmentList(_getFilteredAppointments('all')),
                        _buildAppointmentList(_getFilteredAppointments('pending')),
                        _buildAppointmentList(_getFilteredAppointments('confirmed')),
                        _buildAppointmentList(_getFilteredAppointments('completed')),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAppointments,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text('No appointments in this category'));
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final doctorName = appointment.doctorId is Map ? appointment.doctorId['name'] : 'Doctor';
        final appointmentDate = DateFormat('EEE, MMM d, yyyy - h:mm a').format(appointment.appointmentDate);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appointment.getStatusColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        appointment.getStatusText(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(appointmentDate),
                  ],
                ),
                if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[  
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(appointment.notes!),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (appointment.status == 'pending' || appointment.status == 'confirmed') ...[  
                      TextButton.icon(
                        onPressed: () => _cancelAppointment(appointment.id),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (appointment.status == 'confirmed') ...[  
                      ElevatedButton.icon(
                        onPressed: () {
                          final doctorId = appointment.doctorId is Map 
                              ? appointment.doctorId['_id'] 
                              : appointment.doctorId;
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorChatScreen(
                                doctorId: doctorId,
                                doctorName: doctorName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}