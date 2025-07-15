import 'package:flutter/material.dart';


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

                  },
                  child: Text('Community')),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (_) => DoctorChatPage(doctorId: '1')));
                  },
                  child: Text('Doctor')),
            ],
          )
    );
  }
}
