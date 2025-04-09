import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_entity.dart';

abstract class ChatRoomsEvent extends Equatable {
  const ChatRoomsEvent();

  @override
  List<Object> get props => [];
}

class LoadChatRoomsEvent extends ChatRoomsEvent {}

class ChatRoomsUpdatedEvent extends ChatRoomsEvent {
  final List<ChatRoomEntity> chatRooms;

  const ChatRoomsUpdatedEvent(this.chatRooms);

  @override
  List<Object> get props => [chatRooms];
}

class CreateChatRoomEvent extends ChatRoomsEvent {
  final String name;
  final String description;
  final bool isPublic;

  const CreateChatRoomEvent({
    required this.name,
    required this.description,
    required this.isPublic,
  });

  @override
  List<Object> get props => [name, description, isPublic];
}

class JoinChatRoomEvent extends ChatRoomsEvent {
  final String chatRoomId;

  const JoinChatRoomEvent({required this.chatRoomId});

  @override
  List<Object> get props => [chatRoomId];
}

class LeaveChatRoomEvent extends ChatRoomsEvent {
  final String chatRoomId;

  const LeaveChatRoomEvent({required this.chatRoomId});

  @override
  List<Object> get props => [chatRoomId];
}

class AddUserToChatRoomEvent extends ChatRoomsEvent {
  final String chatRoomId;
  final String userId;

  const AddUserToChatRoomEvent({
    required this.chatRoomId,
    required this.userId,
  });

  @override
  List<Object> get props => [chatRoomId, userId];
}

class RemoveUserFromChatRoomEvent extends ChatRoomsEvent {
  final String chatRoomId;
  final String userId;

  const RemoveUserFromChatRoomEvent({
    required this.chatRoomId,
    required this.userId,
  });

  @override
  List<Object> get props => [chatRoomId, userId];
}

class SearchChatRoomsEvent extends ChatRoomsEvent {
  final String query;

  const SearchChatRoomsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ChatRoomsErrorEvent extends ChatRoomsEvent {
  final String message;

  const ChatRoomsErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}