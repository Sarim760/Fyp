import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dash_chat_2/dash_chat_2.dart';
import '../helper/global_variables.dart';
import '../bloc/auth/authentication_bloc.dart';
import '../helper/chat_message_helper.dart';

class CommunityChatService {
  IO.Socket? _socket;
  String? _currentUserId;
  
  // Callbacks for UI updates
  Function(List<ChatMessage>)? onMessagesUpdated;
  Function(int)? onOnlineCountUpdated;
  Function(Set<String>)? onTypingUsersUpdated;
  Function(String)? onError;
  Function()? onDisconnected;
  Function()? onConnected;

  /// Initialize socket connection with authentication
  Future<ChatUser?> initializeSocket() async {
    try {
      // Check if socket is already connected
      if (_socket != null && _socket!.connected) {
        final auth = await AuthenticationBloc.readAuth();
        final userId = auth?['userId'];
        final username = auth?['username'];
        return ChatUser(id: userId ?? _currentUserId ?? '', firstName: username ?? 'You');
      }
      
      // Disconnect existing socket if any
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }
      
      final auth = await AuthenticationBloc.readAuth();
      final token = auth?['token'];
      final userId = auth?['userId'];
      final username = auth?['username'];
      
      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }
      
      _currentUserId = userId;
      final url = GlobalVariables().localhost;
      
      _socket = IO.io(
        '$url/community',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .build(),
      );
      
      _setupSocketListeners();
      _socket!.connect();
      
      return ChatUser(id: userId, firstName: username ?? 'You');
    } catch (e) {
      onError?.call('Failed to initialize socket: $e');
      return null;
    }
  }
  
  /// Set up all socket event listeners
  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      onConnected?.call();
      _socket!.emit('joinRoom', 'main');
      _fetchCommunityHistory();
    });
    
    _socket?.onError((error) {
      onError?.call('Connection error. Trying to reconnect...');
    });
    
    _socket?.onDisconnect((_) {
      onDisconnected?.call();
      _attemptReconnection();
    });
    
    _socket?.on('communityMessage', (data) {
      final message = ChatMessageHelper.parseIncomingMessage(data);
      if (message != null) {
        _handleNewMessage(message);
      }
    });
    
    _socket?.on('roomUsers', (data) {
      final count = data['count'] ?? 1;
      onOnlineCountUpdated?.call(count);
    });
    
    _socket?.on('typing', (data) {
      if (data['userId'] != _currentUserId) {
        _handleTypingEvent(data['userId'], true);
      }
    });
    
    _socket?.on('stopTyping', (data) {
      if (data['userId'] != _currentUserId) {
        _handleTypingEvent(data['userId'], false);
      }
    });
  }
  
  /// Fetch community chat history
  void _fetchCommunityHistory() {
    _socket?.emitWithAck('getCommunityHistory', 'main', ack: (data) {
      _messages = ChatMessageHelper.parseMessageHistory(data as List);
      onMessagesUpdated?.call(List.from(_messages));
    });
  }
  
  // Local state for managing messages and typing users
  List<ChatMessage> _messages = [];
  Set<String> _typingUsers = {};
  
  /// Handle new incoming message
  void _handleNewMessage(ChatMessage message) {
    _messages.insert(0, message);
    onMessagesUpdated?.call(List.from(_messages));
  }
  
  /// Handle typing events
  void _handleTypingEvent(String userId, bool isTyping) {
    if (isTyping) {
      _typingUsers.add(userId);
    } else {
      _typingUsers.remove(userId);
    }
    onTypingUsersUpdated?.call(Set.from(_typingUsers));
  }
  
  /// Send a message to the community
  void sendMessage(String message, {String? fileUrl, String? fileType}) {
    _socket?.emit('communityMessage', {
      'room': 'main',
      'message': message,
      'fileUrl': fileUrl,
      'fileType': fileType,
    });
  }
  
  /// Send typing indicator
  void sendTyping() {
    _socket?.emit('typing', 'main');
  }
  
  /// Send stop typing indicator
  void sendStopTyping() {
    _socket?.emit('stopTyping', 'main');
  }
  
  /// Attempt to reconnect after disconnection
  void _attemptReconnection() {
    Future.delayed(const Duration(seconds: 3), () {
      // Only reconnect if socket is null, disconnected, or not connected
      if (_socket == null || _socket!.disconnected || !_socket!.connected) {
        initializeSocket();
      }
    });
  }
  
  /// Disconnect and clean up socket
  void disconnect() {
    _socket?.off('communityMessage');
    _socket?.off('roomUsers');
    _socket?.off('typing');
    _socket?.off('stopTyping');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    
    // Clear local state
    _messages.clear();
    _typingUsers.clear();
  }
  
  /// Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;
}