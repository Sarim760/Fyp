import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';
import '../../service/doctor_chat_service.dart';
import '../../bloc/auth/authentication_bloc.dart';
import '../../helper/global_variables.dart';

class DoctorChatScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const DoctorChatScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final List<types.Message> _messages = [];
  late types.User _user = const types.User(id: '');
  late IO.Socket socket;
  final _uuid = const Uuid();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final auth = await AuthenticationBloc.readAuth();
    final token = auth?['token'];
    final userId = auth?['userId'];

    if (token == null || userId == null) return;

    _user = types.User(id: userId);

    final baseUrl = GlobalVariables().localhost;
    socket = IO.io(
      '$baseUrl/private',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      final roomId = _getRoomId(userId, widget.doctorId);
      socket.emit('joinPrivateRoom', roomId);
    });

    socket.on('privateMessage', (data) {
      final message = types.TextMessage(
        author: types.User(id: data['user'] ?? data['senderId']),
        id: data['_id'] ?? _uuid.v4(),
        text: data['message'],
        createdAt: data['timestamp'] is int
            ? data['timestamp']
            : DateTime.tryParse(data['timestamp'] ?? '')?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      );
      _addMessage(message);
    });

    socket.on('typing', (_) {
      setState(() => _isTyping = true);
    });

    socket.on('stopTyping', (_) {
      setState(() => _isTyping = false);
    });

    _loadChatHistory();
  }

  String _getRoomId(String userId, String doctorId) {
    final ids = [userId, doctorId]..sort();
    return ids.join('_');
  }

  void _loadChatHistory() async {
    try {
      final messages = await DoctorChatService().fetchChatHistory(widget.doctorId);
      setState(() {
        _messages.clear();
        _messages.addAll(messages); // If messages are newest-first, reverse them
        _messages.sort((a, b) {
          final aTime = a.createdAt ?? 0;
          final bTime = b.createdAt ?? 0;
          return aTime.compareTo(bTime);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chat history: $e')),
      );
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final authData = await AuthenticationBloc.readAuth();
    final userId = authData?['userId'];
    if (userId == null) return;
    final roomId = _getRoomId(userId, widget.doctorId);
    socket.emit('privateMessage', {
      'roomId': roomId,
      'receiverId': widget.doctorId,
      'message': message.text,
    });
    socket.emit('stopTyping', roomId);
  }


  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(widget.doctorName[0]),
            ),
            const SizedBox(width: 8),
            Text('Dr. ${widget.doctorName}'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: List<types.Message>.from(_messages.reversed),
              onSendPressed: _handleSendPressed,
              user: _user,
              showUserAvatars: true,
              showUserNames: true,
              theme: const DefaultChatTheme(
                primaryColor: Colors.blue,
                inputBackgroundColor: Colors.white,
                inputTextColor: Colors.black,
                backgroundColor: Color(0xFFF5F5F5),
                sentMessageBodyTextStyle: TextStyle(color: Colors.white),
                receivedMessageBodyTextStyle: TextStyle(color: Colors.black87),
              ),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text('Doctor is typing...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}