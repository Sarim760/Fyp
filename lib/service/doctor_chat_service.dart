import 'package:dio/dio.dart';
import '../helper/Global_variables.dart';
import '../bloc/auth/authentication_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class DoctorChatService {
  final Dio _dio = Dio();
  final String _baseUrl = globalvariables().apiString;

  /// Fetch chat history between user and doctor
  Future<List<types.Message>> fetchChatHistory(String doctorId) async {
    try {
      final auth = await AuthenticationBloc.readAuth();
      final token = auth?['token'];
      final userId = auth?['userId'];

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$_baseUrl/chat/private/$doctorId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data is List ? response.data : [];
        return messages.map((message) => _convertToMessage(message, userId)).toList();
      } else {
        throw Exception('Failed to fetch chat history');
      }
    } catch (e) {
      throw Exception('Error fetching chat history: $e');
    }
  }

  /// Convert API message to flutter_chat_types Message
  types.Message _convertToMessage(Map<String, dynamic> message, String currentUserId) {
    final author = types.User(
      id: message['senderId'],
      firstName: message['senderName'] ?? message['senderId'] ?? 'Unknown',
    );

    return types.TextMessage(
      author: author,
      id: message['_id'],
      text: message['message'],
      createdAt: DateTime.parse(message['timestamp']).millisecondsSinceEpoch,
    );
  }
}