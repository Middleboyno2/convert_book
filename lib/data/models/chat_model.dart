import '../../domain/entities/chat_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required String id,
    required String name,
    String? description,
    required DateTime createdAt,
    String? photoUrl,
    required List<String> participantIds,
    required bool isPublic,
    MessageModel? lastMessage,
  }) : super(
    id: id,
    name: name,
    description: description,
    createdAt: createdAt,
    photoUrl: photoUrl,
    participantIds: participantIds,
    isPublic: isPublic,
    lastMessage: lastMessage,
  );

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Parse participant IDs from Firebase (handles both Map and List formats)
    final List<String> participantIds = [];
    if (json['participantIds'] != null) {
      if (json['participantIds'] is Map) {
        // For Realtime DB where participantIds is stored as a map {userId: true}
        (json['participantIds'] as Map).forEach((key, value) {
          if (value == true) {
            participantIds.add(key.toString());
          }
        });
      } else if (json['participantIds'] is List) {
        // For cases where participantIds is stored as a list
        participantIds.addAll((json['participantIds'] as List).map((e) => e.toString()));
      }
    }

    // Parse last message if available
    MessageModel? lastMessage;
    if (json['lastMessage'] != null) {
      lastMessage = MessageModel.fromJson(
        Map<String, dynamic>.from(json['lastMessage']),
      );
    }

    return ChatRoomModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      photoUrl: json['photoUrl'],
      participantIds: participantIds,
      isPublic: json['isPublic'] ?? false,
      lastMessage: lastMessage,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert participantIds to a map for Firebase Realtime DB
    final Map<String, bool> participantIdsMap = {};
    for (var id in participantIds) {
      participantIdsMap[id] = true;
    }

    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
      'participantIds': participantIdsMap,
      'isPublic': isPublic,
      'lastMessage': lastMessage != null
          ? (lastMessage as MessageModel).toJson()
          : null,
    };
  }
}

// Model class for Messages
class MessageModel extends MessageEntity {
  const MessageModel({
    required String id,
    required String chatRoomId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String content,
    required DateTime timestamp,
    List<String>? attachments,
  }) : super(
    id: id,
    chatRoomId: chatRoomId,
    senderId: senderId,
    senderName: senderName,
    senderPhotoUrl: senderPhotoUrl,
    content: content,
    timestamp: timestamp,
    attachments: attachments,
  );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle attachments if present
    List<String>? attachments;
    if (json['attachments'] != null) {
      attachments = List<String>.from(json['attachments']);
    }

    return MessageModel(
      id: json['id'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      senderId: json['senderId'],
      senderName: json['senderName'] ?? 'Anonymous',
      senderPhotoUrl: json['senderPhotoUrl'],
      content: json['content'],
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      attachments: attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'attachments': attachments,
    };
  }
}