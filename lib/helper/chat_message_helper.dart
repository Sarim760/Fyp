import 'package:dash_chat_2/dash_chat_2.dart';

class ChatMessageHelper {
  /// Parse incoming message from socket data
  static ChatMessage? parseIncomingMessage(Map<String, dynamic> data) {
    try {
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
      
      return ChatMessage(
        user: user,
        text: data['message'] ?? '',
        medias: mediaList,
        createdAt: DateTime.tryParse(data['timestamp'] ?? '')?.toLocal() ?? DateTime.now(),
        customProperties: {
          'fileUrl': data['fileUrl'],
          'fileType': data['fileType'],
        },
      );
    } catch (e) {
      // Log error or handle gracefully
      return null;
    }
  }
  
  /// Parse message history from server response
  static List<ChatMessage> parseMessageHistory(List<dynamic> data) {
    return data.map((msg) {
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
      if (msg['fileUrl'] != null && _isImageFile(msg['fileUrl'], msg['fileType'])) {
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
        createdAt: DateTime.tryParse(msg['timestamp'] ?? '')?.toLocal() ?? DateTime.now(),
        customProperties: {
          'fileUrl': msg['fileUrl'],
          'fileType': msg['fileType'],
        },
      );
    }).toList().reversed.toList();
  }
  
  /// Check if file is an image
  static bool _isImageFile(String? fileUrl, String? fileType) {
    if (fileType == 'image') return true;
    if (fileUrl == null) return false;
    
    final url = fileUrl.toLowerCase();
    return url.contains('.jpg') || 
           url.contains('.jpeg') || 
           url.contains('.png') || 
           url.contains('.gif') || 
           url.contains('.webp');
  }
  
  /// Extract media information from ChatMessage
  static Map<String, String?> extractMediaInfo(ChatMessage message) {
    String? fileUrl;
    String? fileType;
    
    if (message.medias != null && message.medias!.isNotEmpty) {
      final media = message.medias!.first;
      fileUrl = media.url;
      fileType = _getFileTypeFromMedia(media);
    }
    
    return {
      'fileUrl': fileUrl,
      'fileType': fileType,
    };
  }
  
  /// Get file type from ChatMedia
  static String _getFileTypeFromMedia(ChatMedia media) {
    switch (media.type) {
      case MediaType.image:
        return 'image';
      case MediaType.video:
        return 'video';
      case MediaType.file:
        return 'file';
      default:
        return 'unknown';
    }
  }
  
  /// Create a ChatMessage with media
  static ChatMessage createMessageWithMedia({
    required ChatUser user,
    required String text,
    required String fileUrl,
    required String fileName,
    String fileType = 'image',
  }) {
    final mediaType = _getMediaTypeFromString(fileType);
    
    return ChatMessage(
      user: user,
      text: text,
      medias: [
        ChatMedia(
          url: fileUrl,
          type: mediaType,
          fileName: fileName,
        )
      ],
      createdAt: DateTime.now(),
      customProperties: {
        'fileUrl': fileUrl,
        'fileType': fileType,
      },
    );
  }
  
  /// Convert string to MediaType
  static MediaType _getMediaTypeFromString(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      case 'file':
        return MediaType.file;
      default:
        return MediaType.image;
    }
  }
  
  /// Validate message content
  static bool isValidMessage(String text, List<ChatMedia>? medias) {
    return text.trim().isNotEmpty || (medias != null && medias.isNotEmpty);
  }
  
  /// Format timestamp for display
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}