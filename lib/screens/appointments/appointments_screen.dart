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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft background for comfort
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Text(
          'Your Care Schedule', // More personal and caring title
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'All Care'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Today'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading your appointments...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.healing, size: 48, color: Colors.red[300]),
                      SizedBox(height: 16),
                      Text(
                        'We\'re having trouble connecting',
                        style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please try again',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchAppointments,
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : _appointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 64, color: theme.primaryColor.withOpacity(0.5)),
                          SizedBox(height: 24),
                          Text(
                            'No appointments scheduled',
                            style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your future appointments will appear here',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAppointmentList(_getFilteredAppointments('all')),
                        _buildAppointmentList(_getFilteredAppointments('pending')),
                        _buildAppointmentList(_getFilteredAppointments('confirmed')),
                        _buildAppointmentList(_getFilteredAppointments('completed')),
                      ],
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchAppointments,
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text('Refresh', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    final theme = Theme.of(context);
    
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: theme.primaryColor.withOpacity(0.5)),
            SizedBox(height: 24),
            Text(
              'No appointments here yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Check other categories or schedule a new appointment',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final doctorName = appointment.doctorId is Map ? appointment.doctorId['name'] : 'Doctor';
        final appointmentDate = DateFormat('EEE, MMM d, yyyy - h:mm a').format(appointment.appointmentDate);
        final isToday = appointment.appointmentDate.day == DateTime.now().day;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isToday ? theme.primaryColor : Colors.transparent, width: isToday ? 2 : 0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'doctor_${appointment.id}',
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.primaryColor.withOpacity(0.1),
                              child: Text(
                                doctorName[0].toUpperCase(),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. $doctorName',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              if (isToday) Text(
                                'Today',
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: appointment.getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: appointment.getStatusColor()),
                        ),
                        child: Text(
                          appointment.getStatusText(),
                          style: TextStyle(
                            color: appointment.getStatusColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 20, color: theme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          appointmentDate,
                          style: TextStyle(fontSize: 15, color: Colors.grey[800], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[  
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note_alt, size: 20, color: theme.primaryColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              appointment.notes!,
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (appointment.status == 'pending' || appointment.status == 'confirmed') ...[  
                        OutlinedButton.icon(
                          onPressed: () => _cancelAppointment(appointment.id),
                          icon: const Icon(Icons.cancel_outlined, size: 20),
                          label: const Text('Cancel Visit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            side: BorderSide(color: Colors.red[400]!),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        SizedBox(width: 12),
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
                          icon: const Icon(Icons.chat_bubble_outline, size: 20),
                          label: const Text('Message Doctor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}