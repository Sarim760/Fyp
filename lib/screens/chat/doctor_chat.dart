import 'package:aiplant/helper/Global_variables.dart';
import 'package:aiplant/model/doctor.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cached_network_image/cached_network_image.dart';

class DoctorChatPage extends StatefulWidget {
  final Doctor_model doctor;

  const DoctorChatPage({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final _storage = const FlutterSecureStorage();
  final List<ChatMessage> messages = [];
  ChatUser? currentUser;
  IO.Socket? socket;
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final userId = await _storage.read(key: 'userId');
    final username = await _storage.read(key: 'username');
    final token = await _storage.read(key: 'token');

    if (userId == null || username == null || token == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    setState(() {
      currentUser = ChatUser(
        id: userId,
        firstName: username,
      );
    });

    // Initialize socket connection for private doctor chat
    final url = globalvariables().localhost;

    // 1. Fetch existing chat history via REST API
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = token;
      final resp = await dio.get('$url/api/chat/private/${widget.doctor.id}');
      final data = resp.data as List<dynamic>;
      setState(() {
        messages.addAll(
          data.map((msg) => ChatMessage(
            user: ChatUser(
              id: msg['senderId'] is String
                  ? msg['senderId']
                  : (msg['senderId']?['_id'] ?? 'unknown'),
              firstName: msg['senderId'] is Map
                  ? (msg['senderId']?['username'] ?? '')
                  : '',
            ),
            text: msg['message'] ?? '',
            createdAt: DateTime.tryParse(msg['timestamp'] ?? '')?.toLocal() ??
                DateTime.now(),
            medias: msg['fileUrl'] != null
                ? [
                    ChatMedia(
                      url: msg['fileUrl'],
                      type: MediaType.image,
                      fileName: 'image',
                    )
                  ]
                : [],
          )).toList(),
        );
      });
    } catch (e) {
      // Handle errors silently for now
    }

    // 2. Setup socket connection
    socket = IO.io(
      '$url/private',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .build(),
    );

    socket!.connect();
    socket!.onConnect((_) {
      socket!.emit('joinPrivateRoom', widget.doctor.chatId);
    });
    // Listen for incoming private messages
    socket!.on('privateMessage', (data) {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            user: ChatUser(
              id: data['senderId'] ?? data['user'],
              firstName: data['senderName'] ?? '',
            ),
            text: data['message'] ?? '',
            createdAt:
                DateTime.tryParse(data['timestamp'] ?? '')?.toLocal() ??
                    DateTime.now(),
            medias: data['fileUrl'] != null
                ? [
                    ChatMedia(
                      url: data['fileUrl'],
                      type: MediaType.image,
                      fileName: 'image',
                    )
                  ]
                : [],
          ),
        );
      });
    });

    socket!.on('typing', (data) {
      // Handle typing indicator if needed
    });

    socket!.on('stopTyping', (data) {
      // Handle stop typing if needed
    });
  }

  void _sendMessage(ChatMessage message) {
    if (message.text.trim().isEmpty && message.medias!.isEmpty) return;

    socket?.emit('privateMessage', {
      'roomId': widget.doctor.chatId,
      'receiverId': widget.doctor.id,
      'message': message.text,
      'fileUrl': message.medias!.isNotEmpty ? message.medias?.first.url : null,
    });

    _controller.clear();
    if (_isTyping) {
      _isTyping = false;
      socket?.emit('stopTyping', widget.doctor.chatId);
    }
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      socket?.emit('typing', widget.doctor.chatId);
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      socket?.emit('stopTyping', widget.doctor.chatId);
    }
  }

  Future<void> _uploadImage() async {
    // Implement image upload similar to community chat
  }

  Widget _buildMediaContainer(ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
    if (message.medias == null || message.medias!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final media = message.medias!.first;
    if (media.type == MediaType.image) {
      return Container(
        constraints: const BoxConstraints(
          maxWidth: 250,
          maxHeight: 250,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CachedNetworkImage(
            imageUrl: media.url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 150,
              width: 150,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 150,
              width: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    socket?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctor.name),
            Text(
              widget.doctor.specialization,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Dr. ${widget.doctor.name}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Specialization: ${widget.doctor.specialization}'),
                      const SizedBox(height: 8),
                      Text('Experience: ${widget.doctor.experience} years'),
                      const SizedBox(height: 8),
                      Text(
                        'Rating: ${widget.doctor.ratings.isNotEmpty ? (widget.doctor.ratings.reduce((a, b) => a + b) / widget.doctor.ratings.length).toStringAsFixed(1) : 'No ratings'}',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : DashChat(
              currentUser: currentUser!,
              messages: messages,
              onSend: _sendMessage,
              messageOptions: MessageOptions(
                showTime: true,
                showCurrentUserAvatar: true,
                currentUserContainerColor: Theme.of(context).primaryColor,
                containerColor: Colors.grey.shade200,
                textColor: Colors.black,
                messageMediaBuilder: _buildMediaContainer,
              ),
              messageListOptions: const MessageListOptions(
                showDateSeparator: true,
              ),
              inputOptions: InputOptions(
                leading: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _uploading ? null : _uploadImage,
                  ),
                ],
                onTextChange: _onTextChanged,
                textController: _controller,
              ),
            ),
    );
  }
}