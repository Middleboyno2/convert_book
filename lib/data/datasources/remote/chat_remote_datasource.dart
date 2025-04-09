import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/error/exceptions.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatRoomModel>> getChatRooms();
  Stream<List<MessageModel>> getMessages(String chatRoomId);
  Future<ChatRoomModel> createChatRoom(String name, String description, bool isPublic);
  Future<String> sendMessage(String chatRoomId, String content, List<String>? attachmentUrls);
  Future<void> joinChatRoom(String chatRoomId);
  Future<void> leaveChatRoom(String chatRoomId);
  Future<void> deleteMessage(String chatRoomId, String messageId);
  Future<bool> isUserInChatRoom(String chatRoomId);
  Future<void> addUserToChatRoom(String chatRoomId, String targetUserId);
  Future<void> removeUserFromChatRoom(String chatRoomId, String targetUserId,);
  Future<List<ChatRoomModel>> searchChatRooms(String query,);
  Future<List<UserModel>> searchUsers(String query);

}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseDatabase database;
  final FirebaseAuth auth;

  ChatRemoteDataSourceImpl({
    required this.database,
    required this.auth,
  });

  String get userId {
    final user = auth.currentUser;
    if (user == null) {
      throw NotAuthenticatedException();
    }
    return user.uid;
  }

  String get userName {
    final user = auth.currentUser;
    if (user == null) {
      throw NotAuthenticatedException();
    }
    return user.displayName ?? 'Anonymous';
  }

  String? get userPhotoUrl {
    final user = auth.currentUser;
    if (user == null) {
      throw NotAuthenticatedException();
    }
    return user.photoURL;
  }

  @override
  Stream<List<ChatRoomModel>> getChatRooms() {
    try {
      // Get public chat rooms
      final publicRoomsStream = database
          .ref('chatRooms')
          .orderByChild('isPublic')
          .equalTo(true)
          .onValue
          .map((event) {
        final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;

        if (data == null) {
          return <ChatRoomModel>[];
        }

        return data.entries.map((entry) {
          final roomData = Map<String, dynamic>.from(entry.value as Map);
          return ChatRoomModel.fromJson({
            ...roomData,
            'id': entry.key,
          });
        }).toList();
      });

      // Get user's private chat rooms
      final userRoomsStream = database
          .ref('userChatRooms/$userId')
          .onValue
          .map((event) async {
        final Map<dynamic, dynamic>? userRoomIds = event.snapshot.value as Map?;

        if (userRoomIds == null) {
          return <ChatRoomModel>[];
        }

        final List<ChatRoomModel> userRooms = [];

        // For each room ID the user is part of, fetch the room data
        for (final entry in userRoomIds.entries) {
          if (entry.value == true) { // Assuming we store roomId: true mapping
            final String roomId = entry.key.toString();

            try {
              final roomSnapshot = await database.ref('chatRooms/$roomId').get();
              if (roomSnapshot.exists) {
                final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);
                userRooms.add(ChatRoomModel.fromJson({
                  ...roomData,
                  'id': roomId,
                }));
              }
            } catch (e) {
              debugPrint('Error fetching room $roomId: $e');
            }
          }
        }

        return userRooms;
      }).asyncMap((event) async => await event); // Convert Future to value

      // Combine both streams
      return Rx.combineLatest2(
        publicRoomsStream,
        userRoomsStream,
            (List<ChatRoomModel> publicRooms, List<ChatRoomModel> userRooms) {
          // Merge and remove duplicates
          final Map<String, ChatRoomModel> mergedRooms = {};

          for (var room in publicRooms) {
            mergedRooms[room.id] = room;
          }

          for (var room in userRooms) {
            mergedRooms[room.id] = room;
          }

          return mergedRooms.values.toList();
        },
      );
    } catch (e) {
      debugPrint('Error getting chat rooms: $e');
      throw ServerException();
    }
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    try {
      return database
          .ref('messages/$chatRoomId')
          .orderByChild('timestamp')
          .limitToLast(100) // Limit to prevent loading too many messages
          .onValue
          .map((event) {
        final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;

        if (data == null) {
          return <MessageModel>[];
        }

        final messages = data.entries.map((entry) {
          final messageData = Map<String, dynamic>.from(entry.value as Map);
          return MessageModel.fromJson({
            ...messageData,
            'id': entry.key,
          });
        }).toList();

        // Sort messages by timestamp (newest first)
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return messages;
      });
    } catch (e) {
      debugPrint('Error getting messages: $e');
      throw ServerException();
    }
  }

  @override
  Future<ChatRoomModel> createChatRoom(String name, String description, bool isPublic) async {
    try {
      final chatRoomRef = database.ref('chatRooms').push();
      final chatRoomId = chatRoomRef.key!;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create participant map (userId: true)
      final Map<String, bool> participants = {
        userId: true
      };

      final chatRoomData = {
        'name': name,
        'description': description,
        'createdAt': timestamp,
        'photoUrl': null,
        'participantIds': participants, // In Realtime DB, using a map is better for queries
        'isPublic': isPublic,
      };

      // Save to chatRooms node
      await chatRoomRef.set(chatRoomData);

      // If the room is private, also add to user's rooms
      if (!isPublic) {
        await database.ref('userChatRooms/$userId/$chatRoomId').set(true);
      }

      // Return the model
      return ChatRoomModel.fromJson({
        ...chatRoomData,
        'id': chatRoomId,
        'createdAt': DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String(),
        // Convert map to list for the entity
        'participantIds': participants.keys.toList(),
      });
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      throw ServerException();
    }
  }

  @override
  Future<String> sendMessage(String chatRoomId, String content, List<String>? attachmentUrls) async {
    try {
      // First check if the user is in the chat room
      final isInRoom = await isUserInChatRoom(chatRoomId);

      // If not in a public room, join automatically
      if (!isInRoom) {
        final roomSnapshot = await database.ref('chatRooms/$chatRoomId').get();

        if (roomSnapshot.exists) {
          final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);
          if (roomData['isPublic'] == true) {
            await joinChatRoom(chatRoomId);
          } else {
            throw Exception('You are not a member of this chat room');
          }
        } else {
          throw NotFoundException();
        }
      }
      // Create new message
      final messageRef = database.ref('messages/$chatRoomId').push();
      final messageId = messageRef.key!;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final messageData = {
        'senderId': userId,
        'senderName': userName,
        'senderPhotoUrl': userPhotoUrl,
        'content': content,
        'timestamp': timestamp,
        'attachments': attachmentUrls,
      };

      // Add message to the messages node
      await messageRef.set(messageData);

      // Update the lastMessage field in the chat room
      final lastMessageData = {
        ...messageData,
        'id': messageId,
      };

      await database.ref('chatRooms/$chatRoomId/lastMessage').set(lastMessageData);

      return messageId;
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (e is NotFoundException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<void> joinChatRoom(String chatRoomId) async {
    try {
      // Add user to participants in chatRoom
      await database.ref('chatRooms/$chatRoomId/participantIds/$userId').set(true);

      // Add chatRoom to user's rooms
      await database.ref('userChatRooms/$userId/$chatRoomId').set(true);
    } catch (e) {
      debugPrint('Error joining chat room: $e');
      throw ServerException();
    }
  }

  @override
  Future<void> leaveChatRoom(String chatRoomId) async {
    try {
      // Remove user from participants in chatRoom
      await database.ref('chatRooms/$chatRoomId/participantIds/$userId').remove();

      // Remove chatRoom from user's rooms
      await database.ref('userChatRooms/$userId/$chatRoomId').remove();
    } catch (e) {
      debugPrint('Error leaving chat room: $e');
      throw ServerException();
    }
  }

  @override
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      // Get the message first to check if the user is the sender
      final messageSnapshot = await database.ref('messages/$chatRoomId/$messageId').get();

      if (!messageSnapshot.exists) {
        throw NotFoundException();
      }

      final messageData = Map<String, dynamic>.from(messageSnapshot.value as Map);
      if (messageData['senderId'] != userId) {
        throw UnauthorizedException();
      }

      // Delete the message
      await database.ref('messages/$chatRoomId/$messageId').remove();

      // Check if this was the last message
      final chatRoomSnapshot = await database.ref('chatRooms/$chatRoomId').get();
      if (!chatRoomSnapshot.exists) {
        throw NotFoundException();
      }

      final chatRoomData = Map<String, dynamic>.from(chatRoomSnapshot.value as Map);
      final lastMessageData = chatRoomData['lastMessage'] as Map?;

      if (lastMessageData != null && lastMessageData['id'] == messageId) {
        // Get the new last message
        final messagesSnapshot = await database
            .ref('messages/$chatRoomId')
            .orderByChild('timestamp')
            .limitToLast(1)
            .get();

        if (messagesSnapshot.exists && messagesSnapshot.children.isNotEmpty) {
          final newLastMessageSnapshot = messagesSnapshot.children.first;
          final newLastMessageId = newLastMessageSnapshot.key!;
          final newLastMessageData = Map<String, dynamic>.from(newLastMessageSnapshot.value as Map);

          await database.ref('chatRooms/$chatRoomId/lastMessage').set({
            ...newLastMessageData,
            'id': newLastMessageId,
          });
        } else {
          // No messages left, remove lastMessage
          await database.ref('chatRooms/$chatRoomId/lastMessage').remove();
        }
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
      if (e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<bool> isUserInChatRoom(String chatRoomId) async {
    try {
      final participantSnapshot = await database.ref('chatRooms/$chatRoomId/participantIds/$userId').get();
      return participantSnapshot.exists && participantSnapshot.value == true;
    } catch (e) {
      debugPrint('Error checking if user is in chat room: $e');
      throw ServerException();
    }
  }


  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Return empty list for very short queries
      if (query.length < 3) return [];

      // Search users by ID or display name
      final usersRef = database.ref('users');
      final userSnapshots = await usersRef
          .orderByChild('displayName')
          .startAt(query)
          .endAt(query + '\uf8ff')
          .limitToFirst(10)
          .get();

      final List<UserModel> results = [];

      if (userSnapshots.exists) {
        for (var child in userSnapshots.children) {
          final userData = Map<String, dynamic>.from(child.value as Map);

          // Don't include current user
          if (child.key != userId) {
            results.add(UserModel.fromJson({
              ...userData,
              'id': child.key,
            }));
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error searching users: $e');
      throw ServerException();
    }
  }

  @override
  Future<void> addUserToChatRoom(String chatRoomId, String targetUserId) async {
    try {
      final roomSnapshot = await database.ref('chatRooms/$chatRoomId').get();

      if (!roomSnapshot.exists) {
        throw NotFoundException();
      }
      final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);

      // Verify it's a private room (only the creator should be able to add users)
      if (roomData['isPublic'] == true) {
        throw Exception('Cannot manually add users to public chat rooms');
      }
      // Verify current user is a participant
      final participants = roomData['participantIds'] as Map?;
      if (participants == null || participants[userId] != true) {
        throw UnauthorizedException();
      }
      // Add user to participants in chatRoom
      await database.ref('chatRooms/$chatRoomId/participantIds/$targetUserId').set(true);

      // Add chatRoom to user's rooms
      await database.ref('userChatRooms/$targetUserId/$chatRoomId').set(true);

    } catch (e) {
      debugPrint('Error adding user to chat room: $e');
      if (e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<void> removeUserFromChatRoom(
      String chatRoomId,
      String targetUserId,
      ) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        throw NotAuthenticatedException();
      }

      final roomSnapshot = await database.ref('chatRooms/$chatRoomId').get();
      if (!roomSnapshot.exists) {
        throw NotFoundException();
      }

      final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);

      // Verify it's a private room
      if (roomData['isPublic'] == true) {
        throw UnauthorizedException(); // Cannot manually remove users from public rooms
      }

      // Check if current user has permission (only creator can remove others)
      final participants = roomData['participantIds'] as Map?;
      if (participants == null || participants[currentUser.uid] != true) {
        throw UnauthorizedException();
      }

      // Cannot remove yourself using this method
      if (targetUserId == currentUser.uid) {
        throw UnauthorizedException('Use leaveChatRoom method to leave a chat room');
      }

      // Remove user from the chat room
      await database.ref('chatRooms/$chatRoomId/participantIds/$targetUserId').remove();

      // Remove chat room from user's list
      await database.ref('userChatRooms/$targetUserId/$chatRoomId').remove();
    } catch (e) {
      debugPrint('Error removing user from chat room: $e');
      if (e is NotAuthenticatedException ||
          e is NotFoundException ||
          e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<List<ChatRoomModel>> searchChatRooms(
      String query,
      ) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw NotAuthenticatedException();
      }

      final _query = query.toLowerCase();

      // Get all chat rooms
      final snapshot = await database.ref('chatRooms').get();

      if (!snapshot.exists) {
        return [];
      }

      final Map<dynamic, dynamic> data = snapshot.value as Map;
      final List<ChatRoomModel> results = [];

      data.forEach((key, value) {
        final roomData = Map<String, dynamic>.from(value as Map);
        final roomName = (roomData['name'] as String).toLowerCase();
        final roomDescription = roomData['description'] != null
            ? (roomData['description'] as String).toLowerCase()
            : '';

        final isMatch = roomName.contains(_query) || roomDescription.contains(_query);
        final isPublic = roomData['isPublic'] ?? false;

        if (isMatch && (isPublic ||
            (roomData['participantIds'] != null &&
                (roomData['participantIds'] as Map).containsKey(user.uid)))) {
          results.add(ChatRoomModel.fromJson({
            ...roomData,
            'id': key,
          }));
        }
      });

      return results;
    } catch (e) {
      debugPrint('Error searching chat rooms: $e');
      if (e is NotAuthenticatedException) {
        rethrow;
      }
      throw ServerException();
    }
  }

}