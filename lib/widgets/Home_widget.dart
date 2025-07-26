import 'package:flutter/material.dart';
import '../screens/chat/doctor_chat_screen.dart';


class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  child: Text('Community')),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorChatScreen(
                          doctorId: '1',
                          doctorName: 'John Doe',
                        ),
                      ),
                    );
                  },
                  child: Text('Doctor')),
            ],
          )
    );
  }
}
