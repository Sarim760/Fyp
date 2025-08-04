import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../helper/global_variables.dart';
import '../../bloc/auth/authentication_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  IO.Socket? socket;
  List<ChatMessage> messages = [];
  ChatUser? currentUser;
  int onlineCount = 1;
  Map<String, String> typingUsers = {}; // userId -> username
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  // Custom message builder for images using CachedNetworkImage
  Widget _buildMediaContainer(ChatMessage message, ChatMessage? previousMessage,
      ChatMessage? nextMessage) {
    if (message.medias == null || message.medias!.isEmpty) {
      return const SizedBox.shrink();
    }

    final media = message.medias!.first;
    if (media.type == MediaType.image) {
      return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
          maxHeight: 200,
        ),
        margin: const EdgeInsets.only(bottom: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            imageUrl: media.url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 100,
              width: 100,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 100,
              width: 100,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Custom message builder to show user names and enhanced UI
  Widget _buildCustomMessage(ChatMessage message, ChatMessage? previousMessage,
      ChatMessage? nextMessage) {
    final bool isCurrentUser = message.user.id == currentUser?.id;
    final bool showUserName = !isCurrentUser &&
        (previousMessage == null || previousMessage.user.id != message.user.id);

    return Container(
      margin: EdgeInsets.only(
        left: isCurrentUser ? 50 : 8,
        right: isCurrentUser ? 8 : 50,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showUserName)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.user.firstName ?? 'User',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCurrentUser) ..._buildAvatar(message),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      if (message.medias != null && message.medias!.isNotEmpty)
                        _buildMediaContainer(
                            message, previousMessage, nextMessage),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isCurrentUser ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isCurrentUser) ..._buildAvatar(message),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAvatar(ChatMessage message) {
    final bool isCurrentUser = message.user.id == currentUser?.id;
    if (isCurrentUser) return [];

    return [
      const SizedBox(width: 8),
      CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          (message.user.firstName?.isNotEmpty == true
                  ? message.user.firstName![0]
                  : 'U')
              .toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _initSocketWithToken();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final bool shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = shouldShow;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Helper method to handle socket connection errors and reconnection
  void _handleSocketError() {
    socket?.onError((error) {
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Connection error. Trying to reconnect...')),
        );
      }
    });

    socket?.onDisconnect((_) {
      if (mounted) {
        setState(() {
          // Update UI to show disconnected state if needed
        });

        // Attempt to reconnect after a delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && (socket == null || socket!.disconnected)) {
            _initSocketWithToken();
          }
        });
      }
    });
  }

  Future<void> _initSocketWithToken() async {
    final auth = await AuthenticationBloc.readAuth();
    final token = auth?['token'];
    final userId = auth?['userId'];
    final username = auth?['username'];
    setState(() {
      currentUser =
          ChatUser(id: userId ?? 'user', firstName: username ?? 'You');
    });
    final url = GlobalVariables().localhost;
    socket = IO.io(
      '$url/community',
      IO.OptionBuilder()
          .setTransports(['websocket']).setAuth({'token': token}).build(),
    );
    socket!.connect();
    // Set up error handling and reconnection
    _handleSocketError();

    socket!.onConnect((_) {
      socket!.emit('joinRoom', 'main');
      socket!.emitWithAck('getCommunityHistory', 'main', ack: (data) {
        setState(() {
          messages = (data as List)
              .map((msg) {
                // Create user from standardized format
                final user = ChatUser(
                  id: msg['senderId'] is String
                      ? msg['senderId']
                      : (msg['senderId']?['_id'] ?? msg['user'] ?? 'unknown'),
                  firstName: msg['senderId'] is Map
                      ? (msg['senderId']?['username'] ?? '')
                      : (msg['user'] is String ? msg['user'] : ''),
                );

                // Handle message with media
                List<ChatMedia>? mediaList;
                if (msg['fileUrl'] != null &&
                    (msg['fileType'] == 'image' ||
                        msg['fileUrl'].toString().contains('.jpg') ||
                        msg['fileUrl'].toString().contains('.jpeg') ||
                        msg['fileUrl'].toString().contains('.png'))) {
                  mediaList = [
                    ChatMedia(
                      url: msg['fileUrl'],
                      type: MediaType.image,
                      fileName: 'image',
                    )
                  ];
                }

                return ChatMessage(
                  user: user,
                  text: msg['message'] ?? '',
                  medias: mediaList,
                  createdAt:
                      DateTime.tryParse(msg['timestamp'] ?? '')?.toLocal() ??
                          DateTime.now(),
                  customProperties: {
                    'fileUrl': msg['fileUrl'],
                    'fileType': msg['fileType'],
                  },
                );
              })
              .toList()
              .reversed
              .toList();
        });
      });
    });
    socket!.on('communityMessage', (data) {
      setState(() {
        // Create user from standardized format
        final user = ChatUser(
          id: data['senderId'] is Map
              ? data['senderId']['_id']
              : (data['user'] ?? 'unknown'),
          firstName: data['senderId'] is Map
              ? data['senderId']['username']
              : (data['user'] is String ? data['user'] : ''),
        );

        // Handle message with media
        List<ChatMedia>? mediaList;
        if (data['fileUrl'] != null && data['fileType'] == 'image') {
          mediaList = [
            ChatMedia(
              url: data['fileUrl'],
              type: MediaType.image,
              fileName: 'image',
            )
          ];
        }

        messages.insert(
          0,
          ChatMessage(
            user: user,
            text: data['message'] ?? '',
            medias: mediaList,
            createdAt: DateTime.tryParse(data['timestamp'] ?? '')?.toLocal() ??
                DateTime.now(),
            customProperties: {
              'fileUrl': data['fileUrl'],
              'fileType': data['fileType'],
            },
          ),
        );
      });
    });
    socket!.on('roomUsers', (data) {
      setState(() {
        onlineCount = data['count'] ?? 1;
      });
    });

    // Handle real-time user online/offline events
    socket!.on('userOnline', (data) {
      setState(() {
        onlineCount++;
      });
    });

    socket!.on('userOffline', (data) {
      setState(() {
        if (onlineCount > 0) {
          onlineCount--;
        }
      });
    });

    socket!.on('typing', (data) {
      if (data['userId'] != currentUser?.id) {
        setState(() {
          typingUsers[data['userId']] = data['username'] ?? 'User';
        });
      }
    });
    socket!.on('stopTyping', (data) {
      if (data['userId'] != currentUser?.id) {
        setState(() {
          typingUsers.remove(data['userId']);
        });
      }
    });
  }

  void _sendMessage(ChatMessage m, {String? fileUrl, String? fileType}) {
    // Handle media attachments from the message object
    String? messageFileUrl = fileUrl;
    String? messageFileType = fileType;

    // If message has media but no fileUrl/fileType was provided, extract from the message
    if (messageFileUrl == null && m.medias != null && m.medias!.isNotEmpty) {
      final media = m.medias!.first;
      messageFileUrl = media.url;
      messageFileType = 'image'; // Default to image for now
    }

    socket?.emit('communityMessage', {
      'room': 'main',
      'message': m.text,
      'fileUrl': messageFileUrl,
      'fileType': messageFileType,
    });

    _controller.clear();
    _stopTyping();

    // Do not add to messages here; wait for server broadcast
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      socket?.emit('typing', 'main');
    } else if (text.isEmpty && _isTyping) {
      _stopTyping();
    }
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      socket?.emit('stopTyping', 'main');
    }
  }

  Future<void> _pickAndSendFile() async {
    setState(() {});
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = pickedFile.name;
      try {
        final url = GlobalVariables().localhost;
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path, filename: fileName),
        });
        final response = await Dio().post(
          '$url/api/chat/upload',
          data: formData,
        );
        if (response.statusCode == 200 && response.data['url'] != null) {
          // Get the full URL from the response
          // Backend now provides complete URLs
          String fileUrl = response.data['url'];
          String fileType = response.data['fileType'] ?? 'image';

          // Create a message with media attachment
          final chatMsg = ChatMessage(
            user: currentUser!,
            text: '', // Optionally add a caption here
            medias: [
              ChatMedia(
                url: fileUrl,
                type: MediaType.image,
                fileName: fileName,
              )
            ],
            createdAt: DateTime.now(),
          );

          // Send the message with explicit file information
          // This ensures the backend receives the file URL even if the socket
          // message format changes in the future
          _sendMessage(
            chatMsg,
            fileUrl: fileUrl,
            fileType: fileType, // Use the fileType from the response
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    socket?.off('communityMessage');
    socket?.off('roomUsers');
    socket?.off('userOnline');
    socket?.off('userOffline');
    socket?.off('typing');
    socket?.off('stopTyping');
    socket?.disconnect();
    socket?.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Convert typing user IDs to ChatUser objects for the typing indicator
    List<ChatUser> typingUsersList = typingUsers.entries
        .map((entry) => ChatUser(id: entry.key, firstName: entry.value))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            socket?.disconnect();
            socket?.dispose();
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Community Chat'),
            Text(
              '$onlineCount ${onlineCount == 1 ? 'person' : 'people'} online',
              style: const TextStyle(fontSize: 12),
            ),
            if (typingUsers.isNotEmpty)
              Text(
                typingUsers.length == 1
                    ? '${typingUsers.values.first} is typing...'
                    : '${typingUsers.length} people are typing...',
                style: const TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: Colors.green),
              ),
          ],
        ),
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    // Chat area
                    Expanded(
                      child: DashChat(
                        currentUser: currentUser!,
                        messages: messages,
                        onSend: _sendMessage,
                        typingUsers: typingUsersList,
                        messageOptions: MessageOptions(
                          showTime: false, // We'll show time in custom builder
                          showCurrentUserAvatar: false,
                          showOtherUsersAvatar:
                              false, // We'll handle avatars in custom builder
                          currentUserContainerColor:
                              Theme.of(context).primaryColor,
                          containerColor: Colors.grey.shade200,
                          textColor: Colors.black,
                          borderRadius: 20.0,
                          messagePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          messageMediaBuilder: _buildMediaContainer,

                          messageRowBuilder: (ChatMessage message,
                              ChatMessage? previousMessage,
                              ChatMessage? nextMessage,
                              bool isFirst,
                              bool isLast) {
                            return _buildCustomMessage(
                                message, previousMessage, nextMessage);
                          },
                        ),
                        messageListOptions: MessageListOptions(
                          showDateSeparator: true,
                          scrollController: _scrollController,
                        ),
                        scrollToBottomOptions: ScrollToBottomOptions(
                          disabled: false,
                          scrollToBottomBuilder: (scrollController) {
                            return Container(
                              margin:
                                  const EdgeInsets.only(bottom: 80, right: 16),
                              child: FloatingActionButton.small(
                                onPressed: _scrollToBottom,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white),
                              ),
                            );
                          },
                        ),
                        inputOptions: InputOptions(
                          leading: [
                            IconButton(
                              icon: const Icon(Icons.photo, color: Colors.grey),
                              onPressed: _pickAndSendFile,
                            ),
                          ],

                          onTextChange: _onTextChanged,
                          textController: _controller,
                          inputDecoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
