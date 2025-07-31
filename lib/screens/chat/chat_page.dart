import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/community_chat_service.dart';
import '../../service/file_upload_service.dart';
import '../../helper/chat_message_helper.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final CommunityChatService _chatService = CommunityChatService();
  final FileUploadService _fileUploadService = FileUploadService();
  
  List<ChatMessage> messages = [];
  ChatUser? currentUser;
  int onlineCount = 1;
  Set<String> typingUsers = {};
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  bool _isUploading = false;

  // Custom message builder for images using CachedNetworkImage
  Widget _buildMediaContainer(ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
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

  @override
  void initState() {
    super.initState();
    _initializeChatService();
  }

  /// Initialize chat service with callbacks
  Future<void> _initializeChatService() async {
    // Set up callbacks for service events
    _chatService.onMessagesUpdated = (newMessages) {
      if (mounted) {
        setState(() {
          messages = newMessages;
        });
      }
    };
    
    _chatService.onOnlineCountUpdated = (count) {
      if (mounted) {
        setState(() {
          onlineCount = count;
        });
      }
    };
    
    _chatService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    };
    
    _chatService.onDisconnected = () {
      if (mounted) {
        setState(() {
          // Update UI to show disconnected state if needed
        });
      }
    };
    
    // Initialize the socket connection
    final user = await _chatService.initializeSocket();
    if (mounted && user != null) {
      setState(() {
        currentUser = user;
      });
    }
  }

  /// Handle new incoming messages
  void _handleNewMessage(ChatMessage message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  void _sendMessage(ChatMessage m, {String? fileUrl, String? fileType}) {
    // Extract media info from message if not provided
    final mediaInfo = ChatMessageHelper.extractMediaInfo(m);
    final messageFileUrl = fileUrl ?? mediaInfo['fileUrl'];
    final messageFileType = fileType ?? mediaInfo['fileType'];
    
    // Send message through service
    _chatService.sendMessage(
      m.text,
      fileUrl: messageFileUrl,
      fileType: messageFileType,
    );
    
    _controller.clear();
    _stopTyping();
    // Do not add to messages here; wait for server broadcast
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _chatService.sendTyping();
    } else if (text.isEmpty && _isTyping) {
      _stopTyping();
    }
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      _chatService.sendStopTyping();
    }
  }

  Future<void> _pickAndSendFile() async {
    if (currentUser == null) return;
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final result = await _fileUploadService.pickAndUploadFromGallery();
      
      if (result.success && result.fileUrl != null) {
        // Create message with media using helper
        final chatMsg = ChatMessageHelper.createMessageWithMedia(
          user: currentUser!,
          text: '', // Optionally add a caption here
          fileUrl: result.fileUrl!,
          fileName: result.fileName ?? 'image',
          fileType: result.fileType ?? 'image',
        );
        
        // Send the message
        _sendMessage(
          chatMsg,
          fileUrl: result.fileUrl,
          fileType: result.fileType,
        );
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.error ?? 'Upload failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _chatService.disconnect();
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
          ],
        ),
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
              messageListOptions: MessageListOptions(
                showDateSeparator: true,
              ),
              inputOptions: InputOptions(

                leading: [
                  IconButton(
                    icon: _isUploading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo),
                    onPressed: _isUploading ? null : _pickAndSendFile,
                  ),
                ],
                onTextChange: _onTextChanged,
                textController: _controller,
              ),

            ),
    );
  }
}