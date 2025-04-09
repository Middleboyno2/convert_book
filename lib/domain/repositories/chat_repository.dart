import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/user_entity.dart';

abstract class ChatRepository {
  // Stream to get all available chat rooms for the current user
  Stream<List<ChatRoomEntity>> getChatRooms();

  // Stream to get all messages for a specific chat room
  Stream<List<MessageEntity>> getMessages(String chatRoomId);

  // Create a new chat room
  Future<Either<Failure, ChatRoomEntity>> createChatRoom(String name,
      String description,
      bool isPublic);

  // Send a message to a chat room
  Future<Either<Failure, String>> sendMessage(String chatRoomId,
      String content,
      List<String>? attachmentUrls);

  // Join a chat room (for public rooms)
  Future<Either<Failure, void>> joinChatRoom(String chatRoomId);

  // Leave a chat room
  Future<Either<Failure, void>> leaveChatRoom(String chatRoomId);

  // Add a user to a chat room (for private rooms)
  Future<Either<Failure, void>> addUserToChatRoom(String chatRoomId,
      String userId);

  // Remove a user from a chat room (for private rooms)
  Future<Either<Failure, void>> removeUserFromChatRoom(String chatRoomId,
      String userId);

  // Search for chat rooms by name
  Future<Either<Failure, List<ChatRoomEntity>>> searchChatRooms(String query);

  // Search for users (to add to private chat rooms)
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);

  // Delete a message
  Future<Either<Failure, void>> deleteMessage(String chatRoomId,
      String messageId);

  // Check if user is in a specific chat room
  Future<Either<Failure, bool>> isUserInChatRoom(String chatRoomId);
}