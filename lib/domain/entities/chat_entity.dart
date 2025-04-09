import 'package:equatable/equatable.dart';

// Entity class for Chat Rooms
class ChatRoomEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String? photoUrl;
  final List<String> participantIds;
  final bool isPublic;
  final MessageEntity? lastMessage;

  const ChatRoomEntity({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.photoUrl,
    required this.participantIds,
    required this.isPublic,
    this.lastMessage,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    createdAt,
    photoUrl,
    participantIds,
    isPublic,
    lastMessage
  ];
}

// Entity class for Messages
class MessageEntity extends Equatable {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String content;
  final DateTime timestamp;
  final List<String>? attachments;

  const MessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.content,
    required this.timestamp,
    this.attachments,
  });

  @override
  List<Object?> get props => [
    id,
    chatRoomId,
    senderId,
    senderName,
    senderPhotoUrl,
    content,
    timestamp,
    attachments,
  ];
}